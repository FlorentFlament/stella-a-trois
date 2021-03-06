; External code
PART_FX_GRAPH equ *
	INCLUDE "fx_graph.asm"
	echo "FX Graph size: ", (* - PART_FX_GRAPH)d, "bytes"
PART_FX_TURN equ *
	INCLUDE "fx_turn.asm"
	echo "FX Turn size: ", (* - PART_FX_TURN)d, "bytes"
PART_FX_TEXT equ *
	INCLUDE "fx_text.asm"
	echo "FX Text size: ", (* - PART_FX_TEXT)d, "bytes"
PART_TIMELINE equ *
	INCLUDE "timeline.asm"
	echo "Timeline size: ", (* - PART_TIMELINE)d, "bytes"

; FX Initializtion - This is a subroutine because this file is loaded
; after the call to fx_init
fx_init SUBROUTINE
	m_fx_turn_init
	m_fx_text_init
	m_fx_wrap_init

	; mirror mode
	lda #$01
	sta CTRLPF
	rts

; FX VBlank code
	MAC m_fx_vblank
	m_fx_wrap_loop
	m_fx_turn_housekeep
	m_fx_text_housekeep
	ldx fx_text_idx
	jsr fx_text_setup

	SET_POINTER ptr, gfx_top_ptr
	jsr fx_graph_setup
	ENDM

; FX Overscan code
	MAC m_fx_overscan
	; Increment time every 64 frames
	lda frame_cnt
	and #$3f
	bne .continue
	inc time
	inc part_time
.continue:
	ENDM

; FX Kernel code
	MAC m_fx_kernel
	; First GFX is 50 lines
	sta WSYNC ; consume out of screen line

	jsr fx_kernel_layout

	lda #$00
	sta COLUPF
	ENDM

fx_kernel_graph_top SUBROUTINE
	ldy #50-1
	jsr fx_graph
	; Setup FX borders
	lda #$00
	sta PF0
	sta PF2
	lda #$40
	sta PF1
	lda #$02
	sta COLUPF
	rts

fx_kernel_graph_bottom SUBROUTINE
	sta WSYNC
	sta WSYNC
	; Second GFX of 34 lines
	SET_POINTER ptr, gfx_bottom_ptr
	jsr fx_graph_setup
	ldy #34-1
	jsr fx_graph
	rts

fx_kernel_layout SUBROUTINE
	lda fx_layout_ptr + 1
	pha
	lda fx_layout_ptr
	pha
	rts

; Helper to do a tiny loop
; Y contains the number of lines to skip - 1
	MAC m_fx_tiny_loop
.loop
	sta WSYNC
	dey
	bne .loop
	ENDM

fx_kernel_intro SUBROUTINE
	jsr fx_kernel_graph_top

	; Empirically found skip values
	ldy #68
	m_fx_tiny_loop

	jsr fx_text_kernel

	ldy #68
	m_fx_tiny_loop

	jsr fx_kernel_graph_bottom
	rts

fx_kernel_title SUBROUTINE
	jsr fx_kernel_graph_top

	; Empirically found skip values
	ldy #53
	m_fx_tiny_loop

	ldx fx_text_idx
	jsr fx_text_setup
	jsr fx_text_kernel
	ldx fx_text_idx
	inx
	jsr fx_text_setup
	jsr fx_text_kernel

	ldy #52
	m_fx_tiny_loop

	jsr fx_kernel_graph_bottom
	rts

fx_kernel_demo SUBROUTINE
	jsr fx_kernel_graph_top
	sta WSYNC

	; Turning shape FX
	m_fx_turn_kernel
	REPEAT 3
	sta WSYNC
	REPEND
	; Text
	jsr fx_text_kernel

	jsr fx_kernel_graph_bottom
	rts

fx_kernel_transition SUBROUTINE
	lda frame_cnt
	and #$3f
	cmp #$20
	bmi .continue
	lda #0

.continue
	and #$0f
	tay
	lda transition_table,Y
	sta tmp

	tay
	beq .upper_end
.upper_loop:
	sta WSYNC
	dey
	bne .upper_loop
.upper_end:
	jsr fx_kernel_graph_top

	; Max 155 lines between the 2 graphs
	asl tmp
	sec
	lda #155
	sbc tmp
	tay
	beq .bottom_end
.bottom_loop:
	sta WSYNC
	dey
	bne .bottom_loop
.bottom_end:
	jsr fx_kernel_graph_bottom

	; Total picture size: 50 + 155 + 34 = 239 lines
	rts

fx_kernel_blank SUBROUTINE
	; Fade-out volume
	lda snd_shift
	cmp #4
	beq .continue
	lda frame_cnt
	and #$3f
	bne .continue
	inc snd_shift
.continue:
	rts

; data

; [int(round(77-abs(math.cos(x/16 * math.pi))*77)) for x in range(16)]
transition_table:
	dc.b $00, $01, $06, $0d, $17, $22, $30, $3e
	dc.b $4d, $3e, $30, $22, $17, $0d, $06, $01

	INCLUDE "gfx_top.asm"
	INCLUDE "gfx_bottom.asm"
