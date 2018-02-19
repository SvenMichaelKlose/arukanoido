;(fn full-sin-wave (x)
;  (+ x
;     (reverse x)
;     (negate x)
;     (reverse (negate x))))

step_smooth:
    jsr half_step_smooth

half_step_smooth:
    ; Move on X axis.
    lda sprites_d,x
    sec
    sbc #$40
    tay
    lda ball_directions_y,y
    asl
    lda ball_directions_y,y
    ror
    sta tmp
    bmi +m
    lda sprites_dx,x
    clc
    adc tmp
    bcc +n
    inc sprites_x,x
    jmp +n

m:  jsr neg
    sta tmp
    lda sprites_dx,x
    sec
    sbc tmp
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

m:  jsr neg
    sta tmp
    lda sprites_dy,x
    sec
    sbc tmp
    bcs +n
    dec sprites_y,x

n:  sta sprites_dy,x
    rts
