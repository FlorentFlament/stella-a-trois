fx_init SUBROUTINE
	lda #<karmeliet
	sta turn_shape_ptr
	lda #>karmeliet
	sta turn_shape_ptr + 1
	lda #<karmeliet_color
	sta turn_color_ptr
	lda #>karmeliet_color
	sta turn_color_ptr + 1
	rts

fx_vblank SUBROUTINE
	rts

fx_kernel SUBROUTINE
	ldy #49
.next_line:
	sta WSYNC
	dey
	bpl .next_line

	jsr fx_turn
	rts

fx_overscan SUBROUTINE
	rts

; External code
	INCLUDE "fx_turn.asm"
