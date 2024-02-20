reflect_ball_obstacle:
    lda #0
    sta side_degrees

    ; Bounce back left.
    lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    lda sprites_x,x
    cmp sprites_x,y
    bcs +r
j:  lda #64
    sta side_degrees
    rts

    ; Bounce back right.
n:  lda sprites_x,x
    cmp sprites_x,y
    bcc -j

    ; Bounce back from top.
    lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    lda sprites_y,x
    cmp sprites_y,y
    bcc +r
j:  lda #128
    sta side_degrees
r:  rts

    ; Bounce back from bottom.
n:  lda sprites_y,x
    cmp sprites_y,y
    bcc -j
    rts
