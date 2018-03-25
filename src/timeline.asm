; N stands for number of items for this part
; P stands for period (in time units) for this part - This must be a power of 2
N_INTRO equ 5
P_INTRO equ 4 ; mask is #$03 - Cumulated time is 20

N_CREDITS equ 4
P_CREDITS equ 2 ; mask is #$01 - CT 28

N_BEERS equ 9
P_BEERS equ 2 ; mask is #$03 - CT 64

N_GREETZ equ 27
P_GREETZ equ 1 ; mask is #$00 - CT 90

N_ENDING equ 4
P_ENDING equ 4

N_TEXTS equ (N_INTRO + N_CREDITS + N_BEERS + N_GREETZ + N_ENDING)

; FX turn next object
	MAC m_fx_turn_next
	; Select next object
	clc
	lda fx_turn_idx
	adc #1
	cmp #(N_BEERS)
	bmi .next
	; Loop on first beer if we reached the end
	lda #0
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
	MAC m_fx_turn_wrap_loop
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

; FX text Wrapping Loop
	MAC m_fx_text_wrap_loop
	lda time
	; The fx_text_period_mask determines when to switch to the next FX
	; For instance:
	; If the value is $00, we switch every '64 frames time unit'
	; If the value is $0f, we switch every 16 time units (when time & 0x0f == 0)
	and fx_text_period_mask
	bne .end
	; Trigger next step every time units
	lda frame_cnt
	and #$3f
	bne .end
	m_fx_text_next
.end:
	ENDM

; FX Wrapping loop (the one that makes FX looping and animating)
	MAC m_fx_wrap_loop
	; Start with current variable values
	m_fx_turn_wrap_loop
	m_fx_text_wrap_loop

	; Update part config if required
	ldy fx_part
	lda t_timeline,Y
	cmp time
	bne .continue
	inc fx_part
	jsr fx_part_setup
.continue:
	ENDM

; Initialize FX wrapping loop
	MAC m_fx_wrap_init
	; fx_part has been initialized to #$00 - everything is fine
	jsr fx_part_setup
	ENDM

; This will call the appropriate part setup function
; According to fx_part value
fx_part_setup:
	ldy fx_part
	lda t_setup_h,Y
	pha
	lda t_setup_l,Y
	pha
	rts ; call setup function

; Setup of different parts
t_intro_setup:
	; TODO change this back to fx_kernel_intro once debugged
	SET_POINTER fx_layout_ptr, (fx_kernel_demo-1)
	lda #(P_INTRO - 1)
	sta fx_text_period_mask
	rts
t_credits_setup:
	lda #(P_CREDITS - 1)
	sta fx_text_period_mask
	rts
t_beers_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_demo-1)
	lda #(P_BEERS - 1)
	sta fx_text_period_mask
	rts
t_greetz_setup:
	lda #(P_GREETZ - 1)
	sta fx_text_period_mask
	rts
t_ending_setup:
	lda #(P_ENDING - 1)
	sta fx_text_period_mask
	rts

T_INTRO equ N_INTRO * P_INTRO
T_CREDITS equ T_INTRO + (N_CREDITS * P_CREDITS)
T_BEERS equ T_CREDITS + (N_BEERS * P_BEERS)
T_GREETZ equ T_BEERS + (N_GREETZ * P_GREETZ)
T_ENDING equ T_GREETZ + (N_ENDING * P_ENDING)
; timeline in 64 frames time units
t_timeline:
	dc.b T_INTRO
	dc.b T_CREDITS
	dc.b T_BEERS
	dc.b T_GREETZ
	dc.b T_ENDING
	dc.b 255 ; END

; Pointers to part dependent setup functions
t_setup_l:
	dc.b #<(t_intro_setup - 1)
	dc.b #<(t_credits_setup  - 1)
	dc.b #<(t_beers_setup - 1)
	dc.b #<(t_greetz_setup - 1)
	dc.b #<(t_ending_setup - 1)
	dc.b #<(t_intro_setup - 1)

t_setup_h
	dc.b #>(t_intro_setup - 1)
	dc.b #>(t_credits_setup  - 1)
	dc.b #>(t_beers_setup - 1)
	dc.b #>(t_greetz_setup - 1)
	dc.b #>(t_ending_setup - 1)
	dc.b #>(t_intro_setup - 1)

fx_turn_shapes_l:
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

	; Intro
	dc.b "   FLUSH    "
	dc.b "  PRESENTS  "
	dc.b "AN ATARI VCS"
	dc.b "  _K INTRO  "
	dc.b " STELLA A^  "

	; Credits
	dc.b "MSX GLAFOUK "
	dc.b "FONT GLAFOUK"
	dc.b " GFX EXOCET "
	dc.b " CODE FLEW  "

	; Beers
	dc.b "            "
	dc.b "   KWACK    "
	dc.b "   ORVAL    "
	dc.b "   DUVEL    "
	dc.b "WESTVLETEREN"
	dc.b " WESTMALLE  "
	dc.b "   CHIMAY   "
	dc.b "   DUVEL    "
	dc.b "   CINEY    "

	; Greetz
	dc.b "  WE LOVE   "
	dc.b "   ALTAIR   "
	dc.b "  CLUSTER   "
	dc.b "   COINE    "
	dc.b " DENTIFRICE "
	dc.b "    DMA     "
	dc.b "  GENESIS   "
	dc.b "  PROJECT   "
	dc.b "    JAC     "
	dc.b "   NOICE    "
	dc.b "  TRILOBIT  "
	dc.b "   WAMMA    "
	dc.b "   XAYAX    "
	dc.b "   BLABLA   "
	dc.b "  HOODLUM   "
	dc.b "   PONK     "
	dc.b " RESISTANCE "
	dc.b "    RSI     "
	dc.b " SECTOR ONE "
	dc.b "   SWYNG    "
	dc.b "    TMP     "
	dc.b "  TRAKTOR   "
	dc.b "    TRBL    "
	dc.b "   UNDEAD   "
	dc.b "  SCENERS   "
	dc.b "  UP ROUGH  "
	dc.b "   X MEN    "

	; End Texts
	dc.b "AND YOU ALL "
	dc.b "PILS IS NICE"
	dc.b "SPECIALS ARE"
	dc.b " REAL BEERS "
