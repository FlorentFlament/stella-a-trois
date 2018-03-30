; N stands for number of items for this part
; P stands for period (in time units) for this part - This must be a power of 2
N_INTRO equ 4
P_INTRO equ 2

N_TITLE equ 1
P_TITLE equ 4

N_CREDITS equ 3
P_CREDITS equ 1

N_TRANSITION equ 1
P_TRANSITION equ 1

N_BEERS equ 8
P_BEERS equ 4

N_WELOVE equ 1
P_WELOVE equ 2

N_GREETZ equ 27
P_GREETZ equ 1

N_ENDING equ 4
P_ENDING equ 2

N_LATEST equ 1
P_LATEST equ 4

N_TEXTS equ (N_INTRO + N_TITLE+1 + N_CREDITS + N_BEERS + N_WELOVE + N_GREETZ + N_ENDING + N_LATEST)

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
	lda part_time
	and #$03
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
	lda part_time
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
	; reinitialize part dedicated time counter
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
	SET_POINTER fx_layout_ptr, (fx_kernel_intro-1)
	lda #(P_INTRO - 1)
	sta fx_text_period_mask
	rts
t_title_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_title-1)
	lda #(P_TITLE - 1)
	sta fx_text_period_mask
	rts
t_credits_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_intro-1)
	inc fx_text_idx
	lda #(P_CREDITS - 1)
	sta fx_text_period_mask
	rts
t_transition_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_transition-1)
	dec fx_text_idx
	lda #(P_TRANSITION - 1)
	sta fx_text_period_mask
	rts
t_beers_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_demo-1)
	lda #(P_BEERS - 1)
	sta fx_text_period_mask
	lda #0
	sta part_time
	sta fx_turn_idx
	sta fx_turn_state
	rts
t_welove_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_demo-1)
	lda #(P_WELOVE - 1)
	sta fx_text_period_mask
	lda #0
	sta part_time
	sta fx_turn_idx
	sta fx_turn_state
	rts
t_greetz_setup:
	lda #(P_GREETZ - 1)
	sta fx_text_period_mask
	rts
t_ending_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_intro-1)
	lda #(P_ENDING - 1)
	sta fx_text_period_mask
	lda #0
	sta part_time
	rts
t_latest_setup:
	lda #(P_LATEST - 1)
	sta fx_text_period_mask
	rts
t_blank_setup:
	SET_POINTER fx_layout_ptr, (fx_kernel_blank-1)
	rts

T_INTRO equ N_INTRO * P_INTRO
T_TITLE equ T_INTRO + (N_TITLE * P_TITLE)
T_CREDITS equ T_TITLE + (N_CREDITS * P_CREDITS)
T_TRANS_1 equ T_CREDITS + (N_TRANSITION * P_TRANSITION)
T_BEERS equ T_TRANS_1 + (N_BEERS * P_BEERS)
T_TRANS_2 equ T_BEERS + (N_TRANSITION * P_TRANSITION)
T_WELOVE equ T_TRANS_2 + (N_WELOVE * P_WELOVE)
T_GREETZ equ T_WELOVE + (N_GREETZ * P_GREETZ)
T_ENDING equ T_GREETZ + (N_ENDING * P_ENDING)
T_LATEST equ T_ENDING + (N_LATEST * P_LATEST)
T_TRANS_3 equ T_LATEST + (N_TRANSITION * P_TRANSITION)
; timeline in 64 frames time units
t_timeline:
	dc.b T_INTRO
	dc.b T_TITLE
	dc.b T_CREDITS
	dc.b T_TRANS_1
	dc.b T_BEERS
	dc.b T_TRANS_2
	dc.b T_WELOVE
	dc.b T_GREETZ
	dc.b T_ENDING
	dc.b T_LATEST
	dc.b T_TRANS_3
	dc.b 0 ; END

; Pointers to part dependent setup functions
t_setup_l:
	dc.b #<(t_intro_setup - 1)
	dc.b #<(t_title_setup - 1)
	dc.b #<(t_credits_setup  - 1)
	dc.b #<(t_transition_setup - 1)
	dc.b #<(t_beers_setup - 1)
	dc.b #<(t_transition_setup - 1)
	dc.b #<(t_welove_setup - 1)
	dc.b #<(t_greetz_setup - 1)
	dc.b #<(t_ending_setup - 1)
	dc.b #<(t_latest_setup - 1)
	dc.b #<(t_transition_setup - 1)
	dc.b #<(t_blank_setup - 1)

t_setup_h
	dc.b #>(t_intro_setup - 1)
	dc.b #>(t_title_setup - 1)
	dc.b #>(t_credits_setup  - 1)
	dc.b #>(t_transition_setup - 1)
	dc.b #>(t_beers_setup - 1)
	dc.b #>(t_transition_setup - 1)
	dc.b #>(t_welove_setup - 1)
	dc.b #>(t_greetz_setup - 1)
	dc.b #>(t_ending_setup - 1)
	dc.b #>(t_latest_setup - 1)
	dc.b #>(t_transition_setup - 1)
	dc.b #>(t_blank_setup - 1)

fx_turn_shapes_l:
	dc.b #<Chimay_v
	dc.b #<Duvel_b
	dc.b #<Ciney_v
	dc.b #<Orval_b
	dc.b #<Duvel_v
	dc.b #<Westvleteren_b
	dc.b #<Kwack_v
	dc.b #<Westmalle_v

fx_turn_shapes_h:
	dc.b #>Chimay_v
	dc.b #>Duvel_b
	dc.b #>Ciney_v
	dc.b #>Orval_b
	dc.b #>Duvel_v
	dc.b #>Westvleteren_b
	dc.b #>Kwack_v
	dc.b #>Westmalle_v

text:
	; 12 first characters are used
	; 4 last characters are here for alignment

	; Intro
	dc.b "   FLUSH    "
	dc.b "  PRESENTS  "
	dc.b "AN ATARI VCS"
	dc.b "  \K INTRO  "

	; Title
	dc.b "   STELLA   "
	dc.b "   A TROIS  "

	; Credits
	dc.b "MSX GLAFOUK "
	dc.b " GFX EXOCET "
	dc.b " CODE FLEW  "

	; Beers
	dc.b "   CHIMAY   "
	dc.b "   DUVEL    "
	dc.b "   CINEY    "
	dc.b "    ORVAL   "
	dc.b "   CHOUFFE  "
	dc.b "WESTVLETEREN"
	dc.b "   KWACK    "
	dc.b " WESTMALLE  "

	; Welove
	dc.b "   WE LOVE  "

	; Greetz
	dc.b "   ALTAIR   "
	dc.b "  CLUSTER   "
	dc.b "    COINE   "
	dc.b " DENTIFRICE "
	dc.b "    DMA     "
	dc.b "   GENESIS  "
	dc.b "  PROJECT   "
	dc.b "     JAC    "
	dc.b "   NOICE    "
	dc.b "  TRILOBIT  "
	dc.b "   WAMMA    "
	dc.b "    XAYAX   "
	dc.b "   BLABLA   "
	dc.b "  HOODLUM   "
	dc.b "    PONK    "
	dc.b " RESISTANCE "
	dc.b "    RSI     "
	dc.b " SECTOR ONE "
	dc.b "    SWYNG   "
	dc.b "    TMP     "
	dc.b "   TRAKTOR  "
	dc.b "    TRBL    "
	dc.b "   UNDEAD   "
	dc.b "  SCENERS   "
	dc.b "  UP ROUGH  "
	dc.b "    X MEN   "
	dc.b "BEETRO CREW "

	; End Texts
	dc.b "AND WE LOVE "
	dc.b "   YOU ALL  "
	dc.b "  CHEERS ]  "
	dc.b "  PROSIT ]  "
	dc.b " ET SANTE ] "
