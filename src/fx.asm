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

fx_main SUBROUTINE
          lda #$00 ; one copy small p0 (Number & Size)
          sta NUSIZ0
          lda #$9e
          sta COLUP0

	ldx #63 ; points
.next_line:
	; Draw a plot
	sta WSYNC
	sta HMOVE
	lda #$01
	sta GRP0

	; Compute next dot position
	txa
	tay
	lda (cylnorm_ptr),Y
	; Fetch corresponding disc
	tay
	lda fx_disc_l,Y
	sta disc_ptr
	lda fx_disc_h,Y
	sta disc_ptr+1
	; Fetch cos value from the disc
	lda frame_cnt
	lsr
	and #$1f
	tay
	lda (disc_ptr),Y
	tay

	; Ensure the plot has been drawned
	sta WSYNC
	; turn off P0
	lda #$00
	sta GRP0
	; Position next plot
	sleep 20
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
	INCLUDE "generated/fx_data.asm"
	INCLUDE "generated/fx_tables.asm"