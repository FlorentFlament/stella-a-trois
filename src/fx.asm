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
	rts

; FX VBlank code
	MAC m_fx_vblank
	m_fx_wrap_loop
	m_fx_turn_housekeep
	m_fx_text_housekeep
	m_fx_text_setup

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
.continue:
	ENDM

; FX Kernel code
	MAC m_fx_kernel
	; First GFX is 50 lines
	ldy #50-1
	sta WSYNC ; consume out of screen line
	jsr fx_graph

	jsr fx_kernel_layout

	sta WSYNC
	sta WSYNC
	; Second GFX of 34 lines
	SET_POINTER ptr, gfx_bottom_ptr
	jsr fx_graph_setup
	ldy #34-1
	jsr fx_graph
	ENDM

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
	; Empirically found skip values
	ldy #71
	m_fx_tiny_loop

	jsr fx_text_kernel

	ldy #70
	m_fx_tiny_loop
	rts

fx_kernel_demo SUBROUTINE
	; Turning shape FX
	m_fx_turn_kernel
	REPEAT 3
	sta WSYNC
	REPEND
	; Text
	jsr fx_text_kernel
	rts

; data
	INCLUDE "gfx_top.asm"
	INCLUDE "gfx_bottom.asm"
