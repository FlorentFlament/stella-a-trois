; Frame per frame house keeping
TURN_DISP equ 8
TURN_FADE_OUT equ (TURN_DISP + 16)
TURN_END equ (TURN_FADE_OUT + 8)

; FX Turn initialization
	MAC m_fx_turn_init
	; Trick to start the demo with the first object
	; This may not be needed at some point
	ENDM

; Loads turn object according to fx_turn_idx
; And stores its pointer to ptr1
	MAC m_fx_turn_get_ptr1
	ldy fx_turn_idx
	lda fx_turn_shapes_l,Y
	sta ptr1
	lda fx_turn_shapes_h,Y
	sta ptr1 + 1
	ENDM

; Update the fx_turn_palette_ptr to point to the appropriate palette
	MAC m_fx_turn_update_palette
	lda fx_turn_idx
	and #$01
	bne .palette_b
	lda #<fx_turn_palette_a
	sta fx_turn_palette_ptr
	lda #>fx_turn_palette_a
	sta fx_turn_palette_ptr + 1
	jmp .end
.palette_b:
	;lda #<fx_turn_palette_b
	lda #<fx_turn_palette_a
	sta fx_turn_palette_ptr
	lda #>fx_turn_palette_a
	sta fx_turn_palette_ptr + 1
.end:
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
	sta fx_turn_brightness
	jmp .inc_cpt
.state32:
	cmp #(TURN_END)
	bcs .end
	sec
	lda #(TURN_END - 1)
	sbc fx_turn_state
	asl
	sta fx_turn_brightness
.inc_cpt:
	; Increment fx_turn_state
	lda frame_cnt
	and #$07
	bne .end
	inc fx_turn_state
.end:
	m_fx_turn_update_palette
	echo "FX Turn Housekeep size: ", (* - FX_TURN_HOUSEKEEP)d, "bytes"
	ENDM

; Line number must be in register X
; Position of the dot must be in register tmp
; Argument is the sprite to use (0 or 1)
	MAC m_fx_position_dot
	txa
	tay
	lda (fx_turn_palette_ptr),Y
	ora fx_turn_brightness
	sta COLUP0
	sta COLUP1
	sleep 7

	lda tmp
	sec
	; Beware ! this loop must not cross a page !
	echo "[FX position dot Loop]", ({1})d, "start :", *
.rough_loop:
	; The pos_star loop consumes 15 (5*3) pixels
	sbc #$0f	      ; 2 cycles
	bcs .rough_loop ; 3 cycles
	echo "[FX position dot Loop]", ({1})d, "end :", *
	sta RESP{1}

	; A register has value is in [-15 .. -1]
	adc #$07 ; A in [-8 .. 6]
	eor #$ff ; A in [-7 .. 7]
	REPEAT 4
	asl
	REPEND
	sta HMP{1} ; Fine position of missile or sprite
	ENDM

; The dot number to compute is in X
; Returns the position of the dot in A reg
; This macro uses Y reg
	MAC m_fx_compute_dot
	txa
	tay
	lda (ptr1),Y

	; Fetch corresponding disc
	tay
	lda fx_disc_l,Y
	sta ptr
	lda fx_disc_h,Y
	sta ptr + 1

	; Fetch angle and add rotation
	clc
	txa
	and #$07
	tay
	lda fx_turn_angle,Y
	adc frame_cnt
	lsr
	and #$1f
	tay
	lda (ptr),Y
.end:
	ENDM



; ptr  is used by the subroutine
; ptr1 is used by the subroutine
; tmp is used
	MAC m_fx_turn_kernel
	lda #$00 ; one copy small p0 (Number & Size)
	sta NUSIZ0
	sta NUSIZ1
	lda #$01

	; Get pointer towards the appropriate object into ptr1
	m_fx_turn_get_ptr1
	ldy #64
.empty_loop:
	dey
	lda (ptr1),Y
	sta WSYNC
	sta WSYNC
	beq .empty_loop

	tya
	tax
.next_line:
	; Compute next dot positions
	m_fx_compute_dot
	sta tmp

	sta WSYNC
	; Don't move sprite 1 anymore
	lda #$00
	sta HMP1
	; Position sprite 0
	m_fx_position_dot 0
	; Turn on sprite 0
	lda #$01
	sta GRP0
	; Commit P0 position
	sta WSYNC
	sta HMOVE
	; Turn off sprite 1
	lda #$00
	sta GRP1

	; Compute next dot positions
	dex
	bmi .end
	m_fx_compute_dot
	sta tmp

	sta WSYNC
	; Don't move sprit 0
	lda #$00
	sta HMP0
	; Position sprite 1
	m_fx_position_dot 1
	; Turn on sprite 1
	lda #$01
	sta GRP1
	; Commit position
	sta WSYNC
	sta HMOVE
	; Turn off sprite 0
	lda #$00
	sta GRP0

	; Loop until last line has been drawn
	dex
	bmi .end
	jmp .next_line

.end:
	lda #0
	sta WSYNC
	sta WSYNC
	sta COLUP0
	sta COLUP1
	sta GRP0
	sta GRP1
	ENDM

fx_turn_angle:
	dc.b $00, $10, $20, $30, $08, $18, $28, $38
