; Wait for joystick or paddle fire.
wait_fire:
l:  lda #0
    sta $9113
    lda $9111
    tax
    and #joy_fire
    beq +n
    txa
    and #joy_left
    bne -l

n:  rts
