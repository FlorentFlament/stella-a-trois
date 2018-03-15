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

	jsr fx_main
	rts

; Position of the dot must be in Y register
	MAC fx_position_dot
	; Position next plot
	sleep 25
	sec
	tya
.rough_loop:
          ; The pos_star loop consumes 15 (5*3) pixels
          sbc #$0f        ; 2 cycles
          bcs .rough_loop ; 3 cycles
	sta RESP0

          ; A register has value is in [-15 .. -1]
          adc #$07 ; A in [-8 .. 6]
          eor #$ff ; A in [-7 .. 7]
          REPEAT 4
          asl
          REPEND
          sta HMP0 ; Fine position of missile or sprite
	ENDM

; The dot number to compute is in X
; Returns the position of the dot in A
	MAC fx_compute_next_dot
	txa
	tay ; both Y and X are used later
	lda (cylnorm_ptr),Y
	; Fetch corresponding disc
	tay
	lda fx_disc_l,Y
	sta disc_ptr
	lda fx_disc_h,Y
	sta disc_ptr+1

	; Fetch angle and add rotation
	clc
	txa
	and #$07
	tay
	lda fx_cylangle,Y
	asl
	adc frame_cnt
	lsr
	and #$1f

	; Load dot position from disc
	tay
	lda (disc_ptr),Y
	ENDM


fx_main SUBROUTINE
          lda #$00 ; one copy small p0 (Number & Size)
          sta NUSIZ0
          lda #$9e
          sta COLUP0

	ldx #63 ; points
.next_line:
	; Compute next dot position
	fx_compute_next_dot
	tay
	; Ensure the plot has been drawned
	sta WSYNC

	; turn off P0
	lda #$00
	sta GRP0
	fx_position_dot

	; Prepare to display next dot
	sta WSYNC
	sta HMOVE
	lda #$01
	sta GRP0

	dex
	bpl .next_line

	lda #0
	sta WSYNC
	sta COLUBK
	sta COLUPF
          sta COLUP0
	sta GRP0
	rts

fx_overscan SUBROUTINE
	rts

; Data
	INCLUDE "fx_data.asm"
	INCLUDE "fx_tables.asm"

fx_cylangle:
	dc.b $00, $08, $10, $18, $04, $0c, $14, $1c
