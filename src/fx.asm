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

; FX Initializtion - This is a subroutine because this file is loaded
; after the call to fx_init
fx_init SUBROUTINE
	jsr fx_text_init
	rts

; FX Timeline
	MAC m_fx_timeline
	lda time
	and #$07
	bne .end
	lda frame_cnt
	and #$fe ; Here frame_cnt is never 0
	bne .end
	lda #0
	sta fx_rot_state
.end:
	ENDM

; FX VBlank code
	MAC m_fx_vblank
	m_fx_timeline
	m_fx_turn_housekeep

	lda #<text
	sta ptr
	lda #>text
	sta ptr + 1
	jsr fx_text_load

	lda #<gfx_top_ptr
	sta ptr
	lda #>gfx_top_ptr
	sta ptr + 1
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

; FX Turn setup
	MAC m_fx_turn_setup
	lda time
	lsr
	lsr
	lsr
	and #$01
	tay
	lda shapes_ptr_l,Y
	sta ptr1
	lda shapes_ptr_h,Y
	sta ptr1 + 1
	ENDM

; FX Kernel code
	MAC m_fx_kernel
	; First GFX is 50 lines
	ldy #50-1
	sta WSYNC ; consume out of screen line
	jsr fx_graph

	; Turning shape FX
	m_fx_turn_setup
	m_fx_turn

	; Second GFX of 34 lines
	lda #<gfx_bottom_ptr
	sta ptr
	lda #>gfx_bottom_ptr
	sta ptr + 1
	jsr fx_graph_setup
	ldy #34-1
	jsr fx_graph

	jsr fx_text
	ENDM

shapes_ptr_l:
	dc.b #<karmeliet
	dc.b #<duvel
shapes_ptr_h:
	dc.b #>karmeliet
	dc.b #>duvel

text:
	dc.b " KARMELIET  "

; data
	INCLUDE "gfx_top.asm"
	INCLUDE "gfx_bottom.asm"
