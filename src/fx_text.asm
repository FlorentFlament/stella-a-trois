; Text to display is pointed to by ptr
; Uses tmp
fx_text_load SUBROUTINE
	ldy #11 ; Load the 11 characters to be displayed
.next:
	; Compute offset in the text_buf buffer and move to X
	tya
	asl
	tax

	; Compute pointer towards LSB towards font
	lda (ptr),Y
	asl
	asl
	asl
	sta text_buf,X

	dey
	bpl .next
	rts

; Initializes text_buf to font MSB
fx_text_init SUBROUTINE
	lda #>fx_text_font
	ldy #23
.next:
	sta text_buf,Y
	dey
	bpl .next
	rts

fx_text SUBROUTINE
	lda #$06 ; 3 copies small (Number & Size)
	sta NUSIZ0
	sta NUSIZ1
	lda #$0a
	sta COLUP0
	lda #$2c
	sta COLUP1

	; TODO Update this to have a finer an customizable position
          ; of the text zone.
	; L45: Position the sprites
	; 12*8 = 96 pixels for the text
	; i.ie 32 pixels on each side (160 - 96)/2
	; +68 HBLANK = 100 pixels for RESP0
	sta WSYNC
	ldx #6  		; 2 - Approx 128 pixels / 15
.posit	dex		; 2
	bne .posit	; 2** (3 if branching)
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
	ldy #$0
.txt_ln:
	sta WSYNC		; 3  78
	sta HMOVE		; 3   3
	lda (text_buf+2),Y	; 5   8
	sta GRP0		; 3  11
	lda (text_buf+6),Y	; 5  16
	sta GRP1		; 3  19
	lda (text_buf+22),Y	; 5  24
	tax		; 2  26 78
	REPEAT 3
	nop
	REPEND     	; 6  32
	lda (text_buf+10),Y	; 5  37
	sta GRP0		; 3  40 120
	lda (text_buf+14),Y	; 5  45
	sta GRP1		; 3  48
	lda (text_buf+18),Y	; 5  53
	sta GRP0		; 3  56
	stx GRP1		; 3  59 154
	sta HMCLR	     	; 3  62
	REPEAT 4
	nop
	REPEND		; 8  70
	sta HMOVE		; 3  73 - End of scanline
	;; even lines
	;; Moving characters 8 pixels to the left
	lda (text_buf+0),Y	; 5   2
	sta GRP0		; 3   5
	lda (text_buf+4),Y	; 5  10
	sta GRP1		; 3  13
	lda (text_buf+20),Y	; 5  18
	tax		; 2  20
	;; Moving characters 8 pixels to the right
	lda #$80		; 2  22
	sta HMP0		; 3  25
	lda #$80		; 2  27
	sta HMP1		; 3  30
	;; Updating sprites graphics
	lda (text_buf+8),Y	; 5  35
	sta GRP0		; 3  38
	lda (text_buf+12),Y	; 5  43
	sta GRP1		; 3  46
	lda (text_buf+16),Y	; 5  51
	sta GRP0		; 3  54
	stx GRP1		; 3  57
	;; looping logic
	iny		; 2  59
	tya		; 2  61
	cmp #8		; 2  63
	bne .txt_ln	; 4(2+2) 67

	lda #$0
	sta GRP0
	sta GRP1
	rts

; data
	INCLUDE fx_text_font.asm