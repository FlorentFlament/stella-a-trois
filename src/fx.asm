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

; FX Initializtion - This is a subroutine because this file is loaded
; after the call to fx_init
fx_init SUBROUTINE
	jsr fx_text_init
	rts

; FX Timeline
	MAC m_fx_timeline
	lda time
	and #$07
	bne .end
	lda frame_cnt
	and #$fe ; Here frame_cnt is never 0
	bne .end
	lda #0
	sta fx_rot_state
.end:
	ENDM

; FX VBlank code
	MAC m_fx_vblank
	m_fx_timeline
	m_fx_turn_housekeep

	lda #<text
	sta ptr
	lda #>text
	sta ptr + 1
	jsr fx_text_load

	lda #<stella_07_top_ptr
	sta ptr
	lda #>stella_07_top_ptr
	sta ptr + 1
	jsr fx_graph_top_prepare
	ENDM

; FX Overscan code
	MAC m_fx_overscan
	; Increment time every 64 frames
	lda frame_cnt
	and #$3f
	bne .continue
	inc time
.continue:
	ENDM

; FX Kernel code
	MAC m_fx_kernel
	; First GFX is 50 lines
	ldy #50-1
	sta WSYNC ; consume out of screen line
	jsr fx_graph

	; Turning shape FX
	jsr fx_turn_prepare
	jsr fx_turn

	; Second GFX of 34 lines
	lda #<stella_07_bottom_ptr
	sta ptr
	lda #>stella_07_bottom_ptr
	sta ptr + 1
	jsr fx_graph_top_prepare
	ldy #34-1
	jsr fx_graph

	jsr fx_text
	ENDM

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


text:
	dc.b " KARMELIET  "

; data
	INCLUDE "stella_07_top.asm"
	INCLUDE "stella_07_bottom.asm"
