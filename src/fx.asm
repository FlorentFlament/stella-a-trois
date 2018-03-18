fx_init SUBROUTINE
	jsr fx_text_init
	rts

fx_vblank SUBROUTINE
	lda #<text
	sta ptr
	lda #>text
	sta ptr + 1
	jsr fx_text_load
	lda #<robot_top_ptr
	sta ptr
	lda #>robot_top_ptr
	sta ptr + 1
	jsr fx_graph_top_prepare
	rts

fx_turn_prepare SUBROUTINE
	lda #<karmeliet
	sta ptr1
	lda #>karmeliet
	sta ptr1 + 1
	rts

; ptr should point towards the graph to display
fx_graph_top_prepare SUBROUTINE
	ldy #2*7-1 ; 7 pointers
.next
	lda (ptr),Y
	sta fx_buf,Y
	dey
	bpl .next
	rts

fx_kernel SUBROUTINE
	; First GFX is 50 lines
	ldy #50-1
	sta WSYNC ; consume out of screen line
	jsr fx_graph

	; Turning shape FX
	jsr fx_turn_prepare
	jsr fx_turn

	; Second GFX of 34 lines
	lda #<robot_bottom_ptr
	sta ptr
	lda #>robot_bottom_ptr
	sta ptr + 1
	jsr fx_graph_top_prepare
	ldy #34-1
	jsr fx_graph

	jsr fx_text

	rts

fx_overscan SUBROUTINE
	rts

text:
	dc.b " KARMELIET  "

; External code
PART_FX_GRAPH equ *
	INCLUDE "fx_graph.asm"
	echo "FX Graph size: ", (* - PART_FX_GRAPH)d, "bytes"
PART_FX_TURN equ *
	INCLUDE "fx_turn.asm"
	echo "FX Turn size: ", (* - PART_FX_TURN)d, "bytes"
PART_FX_TEXT equ *
	INCLUDE "fx_text.asm"
	echo "FX Text size: ", (* - PART_FX_TEXT)d, "bytes"

; data
	INCLUDE "robot_top.asm"
	INCLUDE "robot_bottom.asm"
