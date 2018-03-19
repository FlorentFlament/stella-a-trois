N_TURN_SHAPES equ 9

; FX next object
	MAC m_fx_next
	; Select next object
	lda fx_turn_idx
	clc
	adc #1
	cmp #(N_TURN_SHAPES)
	bne .next
	lda #0
.next
	sta fx_turn_idx
	sta fx_text_idx
	; Reinitialize the state machine
	lda #0
	sta fx_turn_state
	sta fx_text_state
	ENDM

; FX Timeline
	MAC m_fx_timeline
	lda time
	and #$07
	bne .end
	; Trigger next step every 8 time units
	lda frame_cnt
	and #$fe ; Here frame_cnt is never 0
	bne .end
	m_fx_next
.end:
	ENDM

fx_turn_shapes_l:
;	dc.b #<karmeliet
;	dc.b #<duvel
	dc.b #<Orval_v
	dc.b #<Kwack_v
	dc.b #<Orval_b
	dc.b #<Duvel_b
	dc.b #<Westvleteren_b
	dc.b #<Westmalle_v
	dc.b #<Chimay_v
	dc.b #<Duvel_v
	dc.b #<Ciney_v

fx_turn_shapes_h:
;	dc.b #>karmeliet
;	dc.b #>duvel
	dc.b #>Orval_v
	dc.b #>Kwack_v
	dc.b #>Orval_b
	dc.b #>Duvel_b
	dc.b #>Westvleteren_b
	dc.b #>Westmalle_v
	dc.b #>Chimay_v
	dc.b #>Duvel_v
	dc.b #>Ciney_v

text:
	; 12 first characters are used
	; 4 last characters are here for alignment
	dc.b "   ORVAL    ####"
	dc.b "   KWACK    ####"
	dc.b "   ORVAL    ####"
	dc.b "   DUVEL    ####"
	dc.b "WESTVLETEREN####"
	dc.b " WESTMALLE  ####"
	dc.b "   CHIMAY   ####"
	dc.b "   DUVEL    ####"
	dc.b "   CINEY    ####"
