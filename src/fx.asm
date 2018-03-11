fx_init:
	lda #1
	sta seed
	rts

fx_vblank:
	lda seed
	sta buffer
	jsr fill_buffer
	rts

fx_kernel:
	ldy #31 ; stripes
.next_line:
	lda buffer
	sta WSYNC
	sta COLUBK
	lda buffer+1
	sta COLUPF
	lda buffer+2
	sta PF0
	lda buffer+3
	sta PF1
	lda buffer+4
	sta PF2
	jsr fill_buffer
	REPEAT 3
	sta WSYNC
	REPEND
	dey
	bne .next_line

	lda #0
	sta WSYNC
	sta COLUBK
	sta COLUPF
	rts

fx_overscan:
	inc framecnt		; Increment frame counter
	lda framecnt
	and #$0f
	bne .endos
	inc seed
.endos
	rts


; A must contain the previous value of the xor_shift
; A contains the new xor_shift value on return
; Note: tmp is overwritten
xor_shift:
	sta tmp
	asl
	eor tmp
	sta tmp
	lsr
	eor tmp
	sta tmp
	asl
	asl
	eor tmp
	rts

; Uses first element of buffer as last xor_shift value
; Fills the buffer with new pseudo-random values
; Note: Uses X register
fill_buffer:
	ldx #5
	lda buffer
.next:
	jsr xor_shift
	sta buffer,X
	dex
	bpl .next
	rts
