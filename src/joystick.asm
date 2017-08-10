test_fire:
l:  lda $9111
    tax
    and #joy_fire
    beq +r
    txa
    and #joy_left
r:  rts

; Wait for joystick or paddle fire.
wait_fire:
l:  jsr test_fire
    bne -l

wait_fire_released:
l:  lda $9111
    and #joy_left
    beq -l

l:  lda $9111
    and #joy_fire
    beq -l
    rts
