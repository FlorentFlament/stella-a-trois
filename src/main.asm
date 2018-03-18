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
init	CLEAN_START		; Initializes Registers & Memory
	INCLUDE "spookjaune_init.asm"
	jsr fx_init

main_loop:
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T

	; House keeping
	INCLUDE "spookjaune_player.asm"
	inc frame_cnt

	jsr fx_vblank
	jsr wait_timint

	; 248 Kernel lines
	lda #19			; (/ (* 248.0 76) 1024) = 18.40
	sta T1024T
	jsr fx_kernel		; scanline 33 - cycle 23
	jsr wait_timint		; scanline 289 - cycle 30

	; 26 Overscan lines
	lda #22			; (/ (* 26.0 76) 64) = 30.875
	sta TIM64T
	jsr fx_overscan
	jsr wait_timint

	jmp main_loop		; scanline 308 - cycle 15


; X register must contain the number of scanlines to skip
; X register will have value 0 on exit
wait_timint:
	lda TIMINT
	beq wait_timint
	rts

PARTFX equ *
	INCLUDE "fx.asm"
	echo "FX size: ", (* - PARTFX)d, "bytes"

; Data
	INCLUDE "spookjaune_trackdata.asm"

	echo "ROM left: ", ($fffc - *)d, "bytes"
;;;-----------------------------------------------------------------------------
;;; Reset Vector

	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init
