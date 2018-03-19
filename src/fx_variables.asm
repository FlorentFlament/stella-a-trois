; Time referencial - used by FX main loop to orchestrate the parts
; time is incremeneted every 64 frames
time	ds 1

; FX turn state machine
; From 0 to 8
fx_turn_state	ds 1
; FX rotation dot color - Updated by state machine
fx_turn_color	ds 1
; Pointer towards the next shape to be displayed
fx_turn_idx	ds 1

; FX text state machine
fx_text_state	ds 1
; Color of text
fx_text_color	ds 1
; Pointer towards the text to be displayed
fx_text_idx	ds 1

; 12 pointers used to display the text.
; txt_buf is long to initialize so this is done during vblank and must
; not be overriden during the screen display.
; It cannot be mutualized with other FXs ont the screen.
txt_buf	ds 12*2

; 7 pointers used to display graphs
fx_buf	ds 7*2
