fx_init SUBROUTINE
	lda #<karmeliet
	sta cylnorm_ptr
	lda #>karmeliet
	sta cylnorm_ptr+1
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
