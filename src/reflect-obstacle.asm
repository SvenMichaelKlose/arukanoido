reflect_obstacle_h:
    lda sprites_y,x
    and #7
    bne +r

    ; Bounce back left.
    lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    dec scrx
    jsr get_hard_collision
    php
    inc scrx
    plp
    beq +j

    dec scrx
    inc scry
    jsr get_hard_collision
    php
    inc scrx
    dec scrx
    plp
    beq +j
    bne +r


    ; Bounce back right.
n:  inc scrx
    jsr get_hard_collision
    php
    dec scrx
    plp
    bne +n
j:  lda #64
    jmp +l

n:  inc scrx
    inc scry
    jsr get_hard_collision
    php
    dec scrx
    dec scry
    plp
    beq -j

r:  rts

reflect_obstacle:
    lda #0
    sta side_degrees
    sta has_collision

    lda sprites_x,x
    lsr
    lsr
    lsr
    sta scrx
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta scry

    jsr reflect_obstacle_h

reflect_obstacle_v:
    lda sprites_x,x
    and #7
    bne -r

    ; Bounce back from top.
    lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    dec scry
    jsr get_hard_collision
    php
    inc scry
    plp
    bne +r
    beq +j

    ; Bounce back from bottom.
n:  inc scry
    inc scry
    jsr get_hard_collision
    php
    dec scry
    dec scry
    plp
    bne +r
j:  lda #128
l:  clc
    adc side_degrees
    sta side_degrees
    inc has_collision
r:  rts
