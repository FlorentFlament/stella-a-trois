;;;-----------------------------------------------------------------------------
;;; Header

	PROCESSOR 6502
	INCLUDE "include/vcs.h"	; Provides RIOT & TIA memory map
	INCLUDE "include/macro.h"	; This file includes some helper macros


;;;-----------------------------------------------------------------------------
;;; RAM segment

	SEG.U ram
	ORG $0080
framecnt	DS.B	1
seed	DS.B	1
tmp	DS.B	1
buffer	DS.B	5


;;;-----------------------------------------------------------------------------
;;; Code segment

	SEG code
	ORG $F000
init	CLEAN_START		; Initializes Registers & Memory
	jsr fx_init

main_loop:
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T
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

	INCLUDE "src/fx.asm"


;;;-----------------------------------------------------------------------------
;;; Reset Vector

	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init
