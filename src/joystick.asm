; For debugging.

wait_fire:
l:  lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tax
    and #joy_fire
    bne -l

l:  lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tax
    and #joy_fire
    beq -l

    rts
