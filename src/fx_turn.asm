; Frame per frame house keeping
TURN_DISP equ 8
TURN_FADE_OUT equ (TURN_DISP + 40)
TURN_END equ (TURN_FADE_OUT + 8)

	MAC m_fx_turn_housekeep
FX_TURN_HOUSEKEEP equ *
	; 4 possible behaviours:
	; 0-7 : fade-in
	; 8-31 : displayed
	; 32-39 : fade-out
	; 40+ : black
	lda fx_rot_state
	cmp #(TURN_FADE_OUT)
	bcs .state32
	cmp #(TURN_DISP)
	bcs .inc_cpt
	asl
	sta fx_rot_color
	jmp .inc_cpt
.state32:
	cmp #(TURN_END)
	bcs .end
	sec
	lda #(TURN_END - 1)
	sbc fx_rot_state
	asl
	sta fx_rot_color
.inc_cpt:
	; Increment fx_rot_state
	lda frame_cnt
	and #$07
	bne .end
	inc fx_rot_state
.end:
	echo "FX Turn Housekeep size: ", (* - FX_TURN_HOUSEKEEP)d, "bytes"
	ENDM

; Position of the dot must be in tmp register
	MAC m_fx_position_dot
	; Position next plot
	sleep 25
	sec
	lda tmp
.rough_loop:
	; The pos_star loop consumes 15 (5*3) pixels
	sbc #$0f	      ; 2 cycles
	bcs .rough_loop ; 3 cycles
	sta RESP0

	; A register has value is in [-15 .. -1]
	adc #$07 ; A in [-8 .. 6]
	eor #$ff ; A in [-7 .. 7]
	REPEAT 4
	asl
	REPEND
	sta HMP0 ; Fine position of missile or sprite
	ENDM

; The dot number to compute is in tmp1
; Returns the position of the dot in A reg
; This macro uses Y reg
	MAC m_fx_compute_dot
	ldy tmp1
	lda (ptr1),Y
	beq .end ; Keep 0 in A if no point

	; Fetch corresponding disc
	tay
	lda fx_disc_l,Y
	sta ptr
	lda fx_disc_h,Y
	sta ptr + 1

	; Fetch angle and add rotation
	clc
	lda tmp1
	and #$07
	tay
	lda fx_turn_angle,Y
	asl
	adc frame_cnt
	lsr
	and #$1f
	tay
	lda (ptr),Y
.end:
	ENDM

; ptr1 must contain the pointer towards the 'turn shape'
; ptr  is used by the subroutine
; tmp  is used by the subroutine
; tmp1 is used by the subroutine
fx_turn SUBROUTINE
	lda #$00 ; one copy small p0 (Number & Size)
	sta NUSIZ0
	sta PF0
	sta PF1
	sta PF2
	lda #$28
	sta COLUPF
	lda #$01
	sta CTRLPF ; mirror mode
	lda fx_rot_color
	sta COLUP0

	lda #45 ; points
	sta tmp1
.next_line:
	sta WSYNC
	m_fx_compute_dot
	sta tmp
	sta WSYNC ; Make thick plots

	; turn off P0
	lda #$00
	sta GRP0
	; Set Playfield
	;ldy tmp1
	;lda fx_turn_pf,Y
	;sta PF1
	; Set position for next point
	m_fx_position_dot
	; Prepare to display next dot
	sta WSYNC
	sta HMOVE

	; Turn on P0 if we have a dot to display
	lda tmp
	beq .no_dot
	lda #$01
	sta GRP0
.no_dot:
	; Loop until last line has been drawn
	dec tmp1
	bpl .next_line

	lda #0
	sta WSYNC
	sta WSYNC
	sta COLUPF
	sta COLUP0
	sta GRP0
	rts

fx_turn_angle:
	dc.b $00, $08, $10, $18, $04, $0c, $14, $1c

; Data
	INCLUDE "fx_turn_data.asm"
	INCLUDE "fx_turn_tables.asm"

fx_turn_pf:
;	dc.b $00, $aa, $aa, $aa, $00, $54, $54, $54
;	dc.b $00, $aa, $aa, $aa, $00, $54, $54, $54
;	dc.b $00, $aa, $aa, $aa, $00, $54, $54, $54
;	dc.b $00, $aa, $aa, $aa, $00, $54, $54, $54
;	dc.b $00, $aa, $aa, $aa, $00, $54, $54, $54
;	dc.b $00, $aa, $aa, $aa, $00, $00, $00, $00
