reflect_ball_obstacle_h:
    ; Bounce back left.
    lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    lda sprites_x,x
    cmp sprites_x,y
    bcs +j
    rts

    ; Bounce back right.
n:  lda sprites_x,x
    cmp sprites_x,y
    bcc +j
    rts

j:  lda #64
    jmp +l

reflect_ball_obstacle:
    lda #0
    sta side_degrees

    jsr reflect_ball_obstacle_h

reflect_ball_obstacle_v:
    ; Bounce back from top.
    lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    lda sprites_y,x
    cmp sprites_y,y
    bcs +j
    rts

    ; Bounce back from bottom.
n:  lda sprites_y,x
    cmp sprites_y,y
    bcc +j
    rts
j:  lda #128
l:  clc
    adc side_degrees
    sta side_degrees

    sty tmp
    jsr random
    bmi +n
    lda sprites_d,x
    jsr turn_clockwise
    sta sprites_d,x
    ldy tmp
    rts
n:  lda sprites_d,x
    jsr turn_counterclockwise
    sta sprites_d,x
    ldy tmp
    rts
