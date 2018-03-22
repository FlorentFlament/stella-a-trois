N_INTRO equ 5
N_BEERS equ 9
N_GREETZ equ 26
N_TEXTS equ (N_INTRO + N_BEERS + N_GREETZ)

; FX turn next object
	MAC m_fx_turn_next
	; Select next object
	clc
	lda fx_turn_idx
	adc #1
	cmp #(N_INTRO + N_BEERS)
	bmi .next
	; Loop on first beer if we reached the end
	lda #(N_INTRO)
.next:
	sta fx_turn_idx
	; Trigger new turn FX display
	lda #0
	sta fx_turn_state
	ENDM

; FX next text
; 2 periods - Beers, then Greetz - fx_text_idx is a kind of state
	MAC m_fx_text_next
	lda fx_text_idx
	; Initial state is #$ff
	cmp #$ff
	beq .continue
	; Don't do anything if we reached end of texts
	cmp #(N_TEXTS - 1)
	bpl .end
.continue:
	; Select next object
	clc
	lda fx_text_idx
	adc #1
	sta fx_text_idx
	; Trigger new text display for with current text
	lda #0
	sta fx_text_state
.end:
	ENDM

; FX turn timeline
	MAC m_fx_turn_timeline
	lda time
	and #$07
	bne .end
	; Trigger next step every 8 time units
	lda frame_cnt
	and #$3f
	bne .end
	m_fx_turn_next
.end:
	ENDM

; FX text timeline
	MAC m_fx_text_timeline
	; Use fx_text_idx as a state machine
	lda fx_text_idx
	; Initial state is #$ff
	cmp #$ff
	beq .beers
	cmp #(N_INTRO + N_BEERS)
	bpl .greetz
.beers:
	; Trigger next step every 8 time units
	lda time
	and #$07
	bne .end
.greetz
	; Trigger next step every time units
	lda frame_cnt
	and #$3f
	bne .end
	m_fx_text_next
.end:
	ENDM

; FX Timeline
	MAC m_fx_timeline
	m_fx_turn_timeline
	m_fx_text_timeline
	ENDM

empty_beer:
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00

fx_turn_shapes_l:
	dc.b #<empty_beer
	dc.b #<empty_beer
	dc.b #<empty_beer
	dc.b #<empty_beer
	dc.b #<empty_beer

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
	dc.b #>empty_beer
	dc.b #>empty_beer
	dc.b #>empty_beer
	dc.b #>empty_beer
	dc.b #>empty_beer

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
	dc.b "   FLUSH    ####"
	dc.b "  PRESENTS  ####"
	dc.b "AN ATARI VCS####"
	dc.b "  _K INTRO  ####"
	dc.b " STELLA A^  ####"

	dc.b "   ORVAL    ####"
	dc.b "   KWACK    ####"
	dc.b "   ORVAL    ####"
	dc.b "   DUVEL    ####"
	dc.b "WESTVLETEREN####"
	dc.b " WESTMALLE  ####"
	dc.b "   CHIMAY   ####"
	dc.b "   DUVEL    ####"
	dc.b "   CINEY    ####"
	dc.b "  WE LOVE   ####"

	dc.b "   ALTAIR   ####"
	dc.b "  CLUSTER   ####"
	dc.b "   COINE    ####"
	dc.b "    DMA     ####"
	dc.b "  GENESIS   ####"
	dc.b "  PROJECT   ####"
	dc.b "    JAC     ####"
	dc.b "   NOICE    ####"
	dc.b "  TRILOBIT  ####"
	dc.b "   WAMMA    ####"
	dc.b "   XAYAX    ####"
	dc.b "   BLABLA   ####"
	dc.b "  HOODLUM   ####"
	dc.b "   PONK     ####"
	dc.b " RESISTANCE ####"
	dc.b "    RSI     ####"
	dc.b " SECTOR ONE ####"
	dc.b "   SWYNG    ####"
	dc.b "    TMP     ####"
	dc.b "  TRAKTOR   ####"
	dc.b "    TRBL    ####"
	dc.b "   UNDEAD   ####"
	dc.b "  SCENERS   ####"
	dc.b "   X MEN    ####"
	dc.b "AND YOU ALL ####"
