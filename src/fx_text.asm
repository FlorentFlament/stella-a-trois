TEXT_DISP equ 16
TEXT_FADE_OUT equ (TEXT_DISP + 24)
TEXT_END equ (TEXT_FADE_OUT + 16)

; Some house keeping - managing the state machine
	MAC m_fx_text_housekeep
FX_TEXT_HOUSEKEEP equ *
	lda fx_text_state
	cmp #(TEXT_FADE_OUT)
	bcs .state_fadeout
	cmp #(TEXT_DISP)
	bcs .inc_cpt
	; Setup text offset
	and #$0f
	tay
	lda fx_text_offset_table,Y
	sta fx_text_offset
	; Setup text color
	lda fx_text_state
	ora #$d0
	sta fx_text_color
	jmp .inc_cpt
.state_fadeout:
	cmp #(TEXT_END)
	bcs .state_end
	sec
	lda #(TEXT_END - 1)
	sbc fx_text_state
	ora #$d0
	sta fx_text_color
.inc_cpt:
	lda frame_cnt
	and #$03
	bne .end
	inc fx_text_state
	jmp .end
.state_end:
	lda #0
	sta fx_text_color
.end:
	echo "[FX text housekeep] Size: ", (* - FX_TEXT_HOUSEKEEP)d, "bytes"
	ENDM

; Text to display is pointed to by ptr
	MAC m_fx_text_load
	ldy #11 ; Load the 11 characters to be displayed
.next:
	; Compute offset in the txt_buf buffer and move to X
	tya
	asl
	tax

	; Compute pointer towards LSB towards font
	lda (ptr),Y
	asl
	asl
	asl
	sta txt_buf,X
	; MSB
	lda #>fx_text_font
	sta txt_buf+1,X

	dey
	bpl .next
	ENDM

; Setup text to be displayed
; X must contain the text index to fetch
; Uses tmp, ptr
; txt_buf will be filled with the appropriate pointers
fx_text_setup:
	; Multiply by 12 fx_text_idx
	; *4 first
	lda #0
	sta tmp ; MSB
	txa ; LSB
	REPEAT 2
	asl
	rol tmp
	REPEND
	sta ptr
	lda tmp
	sta ptr + 1

	; *8 then
	lda ptr ; LSB
	asl
	rol tmp ; MSB

	; *12 - Add ptr to A and tmp
	clc
	adc ptr
	sta ptr
	lda tmp
	adc ptr + 1
	sta ptr + 1

	; + text
	; No possible carry by multiplying x in [0..255] by 12
	lda ptr
	adc #<text
	sta ptr
	lda ptr + 1
	adc #>text
	sta ptr + 1
	; Then load the text from ptr
	m_fx_text_load
	rts

; Initializes txt_buf to font MSB
	MAC m_fx_text_init
	; Trick to start the demo with the first object
	; This may not be needed at some point
	lda #$ff
	sta fx_text_idx
	ENDM

; FX Text Main Kernel part
; Note that this doesn't need to be aligned
	MAC m_fx_text_kernel_main
	;; Moving characters 8 pixels to the right
	lda #$80
	sta HMP0
	lda #$80
	sta HMP1
	; odd lines - Shifted by 8 pix to the right -> 108
	; Exploiting a bug to move the sprites of +8 pixels
	; This happens when writing HMOVE at the end of the scanline.
	; L54: Display 2*8 lines
	; This uses Y reg
	ldy fx_text_offset
	cpy #8
	beq .end_txt
.txt_ln:
	sta WSYNC		; 3  78
	sta HMOVE		; 3   3
	lda (txt_buf+2),Y	; 5   8
	sta GRP0		; 3  11
	lda (txt_buf+6),Y	; 5  16
	sta GRP1		; 3  19
	lda (txt_buf+22),Y	; 5  24
	tax		; 2  26 78
	REPEAT 3
	nop
	REPEND     	; 6  32
	lda (txt_buf+10),Y	; 5  37
	sta GRP0		; 3  40 120
	lda (txt_buf+14),Y	; 5  45
	sta GRP1		; 3  48
	lda (txt_buf+18),Y	; 5  53
	sta GRP0		; 3  56
	stx GRP1		; 3  59 154
	sta HMCLR	     	; 3  62
	REPEAT 4
	nop
	REPEND		; 8  70
	sta HMOVE		; 3  73 - End of scanline
	;; even lines
	;; Moving characters 8 pixels to the left
	lda (txt_buf+0),Y	; 5   2
	sta GRP0		; 3   5
	lda (txt_buf+4),Y	; 5  10
	sta GRP1		; 3  13
	lda (txt_buf+20),Y	; 5  18
	tax		; 2  20
	;; Moving characters 8 pixels to the right
	lda #$80		; 2  22
	sta HMP0		; 3  25
	lda #$80		; 2  27
	sta HMP1		; 3  30
	;; Updating sprites graphics
	lda (txt_buf+8),Y	; 5  35
	sta GRP0		; 3  38
	lda (txt_buf+12),Y	; 5  43
	sta GRP1		; 3  46
	lda (txt_buf+16),Y	; 5  51
	sta GRP0		; 3  54
	stx GRP1		; 3  57
	;; looping logic
	iny		; 2  59
	tya		; 2  61
	cmp #8		; 2  63
	bne .txt_ln	; 4(2+2) 67
.end_txt:
	ENDM

; FX Text Kernel
; This will be used twice (2 different kernels)
fx_text_kernel SUBROUTINE
	lda #$06 ; 3 copies small (Number & Size)
	sta NUSIZ0
	sta NUSIZ1
	lda fx_text_color
	sta COLUP0
	sta COLUP1

	jsr fx_text_position
	m_fx_text_kernel_main

	; Synchronizing to have the same number of lines whatever the past
	sta WSYNC
	lda #$0
	sta GRP0
	sta GRP1

	; Skip lines to keep the layout if we have an offset
	ldy fx_text_offset
.skip_loop:
	dey
	bmi .end_skip
	sta WSYNC
	sta WSYNC
	jmp .skip_loop
.end_skip:
	rts

; Position the sprites
; 12*8 = 96 pixels for the text
; i.ie 32 pixels on each side (160 - 96)/2
; +68 HBLANK = 100 pixels for RESP0
; Must be aligned !
FX_TEXT_POS_ALIGN equ *
	ALIGN 8
	echo "[FX text pos] Align loss:", (* - FX_TEXT_POS_ALIGN)d, "bytes"
fx_text_position SUBROUTINE
FX_TEXT_POS equ *
	sta WSYNC
	ldx #6  		; 2 - Approx 128 pixels / 15
.posit	dex		; 2
	bne .posit	; 2** (3 if branching)
	echo "[FX text pos] Loop:", (* - FX_TEXT_POS)d, "bytes"
	sta RESP0		; 3 34 (2 + 5*(2+3) + 4 + 3)
	; 102 pixels - 68 = 34 ; -> 39 observerd on Stella
	nop
	sta RESP1
	lda #$70		; -> now 100 pixels
	sta HMP0
	lda #$60
	sta HMP1
	sta WSYNC
	sta HMOVE

	; Don't touch HMPx for 24 cycles
	ldx #4
.dont_hmp	dex
	bpl .dont_hmp
	rts

; data
fx_text_offset_table:
	dc.b 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1, 1, 1, 0, 0, 0, 0
