fx_init SUBROUTINE
	jsr fx_text_init
	rts

fx_vblank SUBROUTINE
	lda #<text
	sta ptr
	lda #>text
	sta ptr + 1
	jsr fx_text_load
	rts

fx_turn_prepare SUBROUTINE
	lda #<karmeliet
	sta ptr1
	lda #>karmeliet
	sta ptr1 + 1
	lda #<karmeliet_color
	sta ptr2
	lda #>karmeliet_color
	sta ptr2 + 1
	rts

fx_kernel SUBROUTINE
	; First GFX is 50 lines
	ldy #49
.gfx1_next_line:
	sta WSYNC
	dey
	bpl .gfx1_next_line

	; Turning shape FX
	jsr fx_turn_prepare
	jsr fx_turn

	; Second GFX of 34 lines
	ldy #33
.gfx2_next_line:
	sta WSYNC
	dey
	bpl .gfx2_next_line

	jsr fx_text

	rts

fx_overscan SUBROUTINE
	rts

text:
	dc.b " KARMELIET  "

; External code
	INCLUDE "fx_turn.asm"
	INCLUDE "fx_text.asm"