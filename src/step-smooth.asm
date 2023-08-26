;(fn full-sin-wave (x)
;  (+ x
;     (reverse x)
;     (negate x)
;     (reverse (negate x))))

half_step_smooth:
    ; Move on X axis.
    lda sprites_d,x     ; Get direction.
    sec
    sbc #$40
    tay
    lda ball_directions_y,y
    asl                 ; Store sign in carry flag.
    lda ball_directions_y,y
    ror                 ; Signed division by 2 to keep aspect ratio.
    sta tmp
    bmi +m

    lda sprites_dx,x
    clc
    adc tmp
    bcc +n
    inc sprites_x,x
    jmp +n

m:  lda sprites_dx,x
    clc
    adc tmp
    bcs +n
    dec sprites_x,x

n:  sta sprites_dx,x

    ; Move on Y axis.
    ldy sprites_d,x
    lda ball_directions_y,y
    bmi +m

    lda sprites_dy,x
    clc
    adc ball_directions_y,y
    bcc +n
    inc sprites_y,x
    jmp +n

m:  lda sprites_dy,x
    clc
    adc ball_directions_y,y
    bcs +n
    dec sprites_y,x

n:  sta sprites_dy,x
    rts
