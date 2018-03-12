fx_init SUBROUTINE
	rts

fx_vblank SUBROUTINE
	rts

fx_kernel SUBROUTINE
          lda #$00 ; one copy small p0 (Number & Size)
          sta NUSIZ0
          lda #$9e
          sta COLUP0
          lda #$01
          sta GRP0

	ldy #63 ; points
.next_line:
	sta WSYNC
	lda #$00
	sta GRP0 ; turn off P0

	; Compute next dot position
	lda karmeliet,Y
	sleep 30
	sec
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

	; Now draw the plot
	sta WSYNC
	sta HMOVE
	lda #$01
	sta GRP0

	dey
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
