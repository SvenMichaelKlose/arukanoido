reflect_h:
    ; Bounce back left.
    lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    ldy ball_x
    dey
    tya
    ldy ball_y
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back right.
n:  ldy ball_x
    iny
    tya
    ldy ball_y
    jsr get_soft_collision
    bne +r
j:  lda #64
    jmp +l

reflect:
    lda #0
    sta side_degrees
    sta has_collision

    ; Get centre position of ball.
    ldy sprites_x,x
    iny
    sty ball_x
    tya
    ldy sprites_y,x
    iny
    iny
    sty ball_y
    jsr reflect_h

reflect_v:
    ; Bounce back from top.
    lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    lda ball_x
    ldy ball_y
    dey
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back from bottom.
n:  lda ball_x
    ldy ball_y
    iny
    jsr get_soft_collision
    bne +r
j:  lda #128
l:  clc
    adc side_degrees
    sta side_degrees
    inc has_collision
    jsr hit_brick
    bcs +r
    inc has_hit_brick

r:  rts

apply_reflection:
    lda sprites_d,x     ; Get degrees.
    sec
    sbc side_degrees    ; Rotate back to zero degrees.
    jsr neg             ; Get opposite deviation from general direction.
    clc
    adc side_degrees    ; Rotate back to original axis.
    clc
    adc #128            ; Rotate to opposite direction.
    sta sprites_d,x
    rts
