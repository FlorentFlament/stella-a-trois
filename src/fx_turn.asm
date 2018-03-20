; Frame per frame house keeping
TURN_DISP equ 8
TURN_FADE_OUT equ (TURN_DISP + 40)
TURN_END equ (TURN_FADE_OUT + 8)

; FX Turn initialization
	MAC m_fx_turn_init
	; Trick to start the demo with the first object
	; This may not be needed at some point
	lda #$ff
	sta fx_turn_idx
	ENDM

; FX Turn setup
; Loads turn object according to fx_turn_idx
; And stores its pointer to ptr1
	MAC m_fx_turn_get_ptr1
	ldy fx_turn_idx
	lda fx_turn_shapes_l,Y
	sta ptr1
	lda fx_turn_shapes_h,Y
	sta ptr1 + 1
	ENDM

; FX Turn House Keeping Macro
	MAC m_fx_turn_housekeep
FX_TURN_HOUSEKEEP equ *
	; 4 possible behaviours:
	; 0-7 : fade-in
	; 8-31 : displayed
	; 32-39 : fade-out
	; 40+ : black
	lda fx_turn_state
	cmp #(TURN_FADE_OUT)
	bcs .state32
	cmp #(TURN_DISP)
	bcs .inc_cpt
	asl
	sta fx_turn_color
	jmp .inc_cpt
.state32:
	cmp #(TURN_END)
	bcs .end
	sec
	lda #(TURN_END - 1)
	sbc fx_turn_state
	asl
	sta fx_turn_color
.inc_cpt:
	; Increment fx_turn_state
	lda frame_cnt
	and #$07
	bne .end
	inc fx_turn_state
.end:
	echo "FX Turn Housekeep size: ", (* - FX_TURN_HOUSEKEEP)d, "bytes"
	ENDM

; Position of the dot must be in tmp register
FXPOS_ALIGNED equ *
	ALIGN 32
	echo "Loss due to alignment (FX Position Dot):", (* - FXPOS_ALIGNED)d, "bytes"
fx_position_dot SUBROUTINE
ROUGH_LOOP_START equ *
	sta WSYNC
	; turn off P0
	lda #$00
	sta GRP0
	sleep 25

	lda tmp
	sec
	; Beware ! this loop must not cross a page !
.rough_loop:
	; The pos_star loop consumes 15 (5*3) pixels
	sbc #$0f	      ; 2 cycles
	bcs .rough_loop ; 3 cycles
	echo "Rough Loop Length:", (* - ROUGH_LOOP_START)d, "bytes"
	sta RESP0

	; A register has value is in [-15 .. -1]
	adc #$07 ; A in [-8 .. 6]
	eor #$ff ; A in [-7 .. 7]
	REPEAT 4
	asl
	REPEND
	sta HMP0 ; Fine position of missile or sprite
	rts

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

; ptr  is used by the subroutine
; ptr1 is used by the subroutine
; tmp  is used by the subroutine
; tmp1 is used by the subroutine
	MAC m_fx_turn_kernel
	lda #$00 ; one copy small p0 (Number & Size)
	sta NUSIZ0
	sta PF0
	sta PF1
	sta PF2
	lda #$28
	sta COLUPF
	lda #$01
	sta CTRLPF ; mirror mode
	lda fx_turn_color
	sta COLUP0

	; Get pointer towarts the appropriate object into ptr1
	m_fx_turn_get_ptr1
	lda #45 ; points
	sta tmp1
.next_line:
	sta WSYNC
	m_fx_compute_dot
	sta tmp
	jsr fx_position_dot
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
	ENDM

fx_turn_angle:
	dc.b $00, $08, $10, $18, $04, $0c, $14, $1c

; Data
	INCLUDE "fx_turn_data.asm"
	INCLUDE "fx_turn_tables.asm"
