; Time referencial - used by FX main loop to orchestrate the parts
; time is incremeneted every 64 frames
time	ds 1

; FX rotation state machine
; From 0 to 8
rot_state	ds 1

; 12 pointers used to display the text.
; txt_buf is long to initialize so this is done during vblank and must
; not be overriden during the screen display.
; It cannot be mutualized with other FXs ont the screen.
txt_buf	ds 12*2

; 7 pointers used to display graphs
fx_buf	ds 7*2
