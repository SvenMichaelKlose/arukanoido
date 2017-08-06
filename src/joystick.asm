; Wait for joystick or paddle fire.
wait_fire:
l:  lda #0
    sta $9113
    lda $9111
    tax
    and #joy_fire
    beq wait_joystick_fire_released
    txa
    and #joy_left
    bne -l

wait_paddle_fire_released:
l:  lda #0
    sta $9113
    lda $9111
    and #joy_left
    beq -l
    rts

wait_joystick_fire_released:
l:  lda #0
    sta $9113
    lda $9111
    and #joy_fire
    beq -l
    rts
