get_joystick:
    ; Joystick left?
    lda $9111
    and #joy_left
    bne +n
    lda #255
    rts
    ; Joystick right?
n:  lda #0          ; Fetch rest of joystick status.
    sta $9122
    ldy #255
    lda $9120
    sty $9122
    bmi +n
    lda #1
    rts
n:  lda #0
    rts
