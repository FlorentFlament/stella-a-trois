; ptr should point towards the graph to display
; This code is used to setup both top and bottom graphs.
fx_graph_setup SUBROUTINE
	ldy #2*7-1 ; 7 pointers
.next
	lda (ptr),Y
	sta fx_buf,Y
	dey
	bpl .next
	rts

; fx_buf should have pointers towards graph data
; fx_buf    -> COLUPF
; fx_buf+2  -> PF0
; fx_buf+4  -> PF1
; fx_buf+6  -> PF2
; Y should contains the number of lines to display -1
; Note that this code is called for both parts of the graphx
fx_graph SUBROUTINE
.next
	sta WSYNC
	lda (fx_buf),Y
	sta COLUPF
	lda (fx_buf+2),Y
	sta PF0
	lda (fx_buf+4),Y
	sta PF1
	lda (fx_buf+6),Y
	sta PF2
	dey
	bpl .next
	sta WSYNC
	rts
