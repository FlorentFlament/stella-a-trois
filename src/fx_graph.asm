; fx_buf should have pointers towards graph data
; fx_buf    -> COLUPF
; fx_buf+2  -> PF0
; fx_buf+4  -> PF1
; fx_buf+6  -> PF2
; fx_buf+8  -> PF3
; fx_buf+10 -> PF4
; fx_buf+12 -> PF5
; Y should contains the number of lines to display -1
fx_graph SUBROUTINE
	lda #$00
	sta CTRLPF ; non-mirror mode

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
	lda (fx_buf+8),Y
	sta PF0
	lda (fx_buf+10),Y
	sta PF1
	lda (fx_buf+12),Y
	sta PF2
	dey
	bpl .next
	sta WSYNC

	lda #0
	sta PF0
	sta PF1
	sta PF2
	rts
