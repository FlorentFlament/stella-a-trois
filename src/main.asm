;;;-----------------------------------------------------------------------------
;;; Header

	PROCESSOR 6502
	INCLUDE "vcs.h"	; Provides RIOT & TIA memory map
	INCLUDE "macro.h"	; This file includes some helper macros


;;;-----------------------------------------------------------------------------
;;; RAM segment

	SEG.U ram
	ORG $0080
frame_cnt	ds 1
tmp	ds 1
tmp1	ds 1
ptr	ds 2
ptr1	ds 2
	INCLUDE "spookjaune_variables.asm"
	INCLUDE "fx_variables.asm"


;;;-----------------------------------------------------------------------------
;;; Code segment

	SEG code
	ORG $F000
; Loading a couple of data to have it aligned without loosing space
	INCLUDE "fx_text_font.asm"
	INCLUDE "fx_turn_data.asm"
	INCLUDE "fx_turn_tables.asm"
	INCLUDE "fx_turn_palettes.asm"

; Sound fadeoff macro
	MAC m_sound_fadeoff
	; Clean snd_vol registers
	lda snd_vol
	and #$0f
	sta snd_vol
	lda snd_vol+1
	and #$0f
	sta snd_vol+1

	; Shift sound volume according to snd_shift
	ldx snd_shift
	beq .dont_shift_volume
.loop_shift_volume:
	lsr snd_vol
	lsr snd_vol+1
	dex
	bne .loop_shift_volume
.dont_shift_volume:
	lda snd_vol
	sta AUDV0
	lda snd_vol+1
	sta AUDV1
	ENDM

; Then the remaining of the code
init	CLEAN_START		; Initializes Registers & Memory

	; Initialization
	INCLUDE "spookjaune_init.asm"
	jsr fx_init
	jmp main_loop

	; Import FX macros and subroutines
	INCLUDE "fx.asm"

main_loop SUBROUTINE
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

	; ===== VBLANK =====
	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T
	INCLUDE "spookjaune_player.asm"
	m_sound_fadeoff
	m_fx_vblank
	jsr wait_timint

	; ===== KERNEL =====
	; 248 Kernel lines
	lda #19			; (/ (* 248.0 76) 1024) = 18.40
	sta T1024T
	m_fx_kernel		; scanline 33 - cycle 23
	jsr wait_timint		; scanline 289 - cycle 30

	; ===== OVERSCAN ======
	; 26 Overscan lines
	lda #22			; (/ (* 26.0 76) 64) = 30.875
	sta TIM64T
	inc frame_cnt
	m_fx_overscan
	jsr wait_timint

	jmp main_loop		; scanline 308 - cycle 15


; X register must contain the number of scanlines to skip
; X register will have value 0 on exit
wait_timint:
	lda TIMINT
	beq wait_timint
	rts

; Data
	INCLUDE "spookjaune_trackdata.asm"
	echo "ROM left: ", ($fffc - *)d, "bytes"
;;;-----------------------------------------------------------------------------
;;; Reset Vector

	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init
