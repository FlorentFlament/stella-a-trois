; Position of the dot must be in tmp register
	MAC fx_position_dot
	; Position next plot
	sleep 7
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
	MAC fx_compute_dot
	ldy tmp1
	lda (ptr1),Y
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
	ENDM

; ptr1 must contain the pointer towards the 'turn shape'
; ptr2 must contain the pointer towards the 'turn color'
; ptr  is used by the subroutine
; tmp  is used by the subroutine
; tmp1 is used by the subroutine
fx_turn SUBROUTINE
	lda #$00 ; one copy small p0 (Number & Size)
	sta NUSIZ0
	sta PF0
	sta PF1
	sta PF2
	lda #$22
	sta COLUPF
	lda #$01
	sta CTRLPF

	lda #63 ; points
	sta tmp1
.next_line:
	; Compute next dot position
	fx_compute_dot
	sta tmp
	; Ensure the plot has been drawned
	sta WSYNC

	; turn off P0
	lda #$00
	sta GRP0
	; Set Playfield
	ldy tmp1
	lda fx_turn_pf,Y
	sta PF1
	; Set the appropriate dot color
	lda (ptr2),Y
	sta COLUP0
	; Set position for next point
	fx_position_dot
	; Prepare to display next dot
	sta WSYNC
	sta HMOVE

	; Turn on P0
	lda #$01
	sta GRP0
	; Loop until last line has been drawn
	dec tmp1
	bpl .next_line

	lda #0
	sta WSYNC
	sta COLUBK
	sta COLUPF
	sta COLUP0
	sta GRP0
	rts

fx_turn_angle:
	dc.b $00, $08, $10, $18, $04, $0c, $14, $1c

; Data
	INCLUDE "fx_data.asm"
	INCLUDE "fx_tables.asm"

	ALIGN 256
karmeliet_color:
	dc.b $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	dc.b $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	dc.b $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	dc.b $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c
	dc.b $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c
	dc.b $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c
	dc.b $2c, $2c, $2c, $2c, $2c, $2c, $0e, $0e
	dc.b $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
fx_turn_pf:
	dc.b $00, $aa, $aa, $aa, $aa, $aa, $aa, $00
	dc.b $00, $54, $54, $54, $54, $54, $54, $00
	dc.b $00, $aa, $aa, $aa, $aa, $aa, $aa, $00
	dc.b $00, $54, $54, $54, $54, $54, $54, $00
	dc.b $00, $aa, $aa, $aa, $aa, $aa, $aa, $00
	dc.b $00, $54, $54, $54, $54, $54, $54, $00
	dc.b $00, $aa, $aa, $aa, $aa, $aa, $aa, $00
	dc.b $00, $54, $54, $54, $54, $54, $54, $00

