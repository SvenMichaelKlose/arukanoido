reflect_ball_obstacle:
    lda #0
    sta side_degrees

reflect_ball_obstacle_h:
    ; Bounce back left.
    lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    lda sprites_x,x
    cmp sprites_x,y
    bcs +j
    bcc reflect_ball_obstacle_v ; (jmp)

    ; Bounce back right.
n:  lda sprites_x,x
    cmp sprites_x,y
    bcs reflect_ball_obstacle_v

j:  lda #64
    bne +l                  ; (jmp)

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
    rts
