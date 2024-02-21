half_step_smooth:
    ; Move on X axis.
    lda sprites_d,x     ; Get direction.
    sec
    sbc #$40            ; Translate sine from Y axis.
    tay
    lda ball_directions_y,y
    asl                 ; Store sign in carry flag.
    lda ball_directions_y,y
    ror                 ; Signed division by 2 to keep aspect ratio.
    clc
    bmi +m

    adc sprites_dx,x
    bcc +n
    inc sprites_x,x
    bne +o              ; (jmp)

m:  adc sprites_dx,x
    bcs +n
    dec sprites_x,x

o:  inc position_has_changed
n:  sta sprites_dx,x

    ; Move on Y axis.
    ldy sprites_d,x
    lda ball_directions_y,y
    clc
    bmi +m

    adc sprites_dy,x
    bcc +n
    inc sprites_y,x
    bne +o              ; (jmp)

m:  adc sprites_dy,x
    bcs +n
    dec sprites_y,x

o:  inc position_has_changed
n:  sta sprites_dy,x
    rts
