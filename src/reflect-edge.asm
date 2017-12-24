reflect_edge:
    lda #0
    sta side_degrees
    sta has_collision

    ; Bounce back from bottom right.
    lda sprites_d,x
    and #%11000000
    bne +n
    ldy ball_x
    iny
    tya
    ldy ball_y
    iny
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back from top right.
n:  cmp #4
    bne +n
    ldy ball_x
    iny
    tya
    ldy ball_y
    dey
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back from top left.
n:  cmp #8
    bne +n
    ldy ball_x
    dey
    tya
    ldy ball_y
    dey
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back from bottom left.
n:  ldy ball_x
    dey
    tya
    ldy ball_y
    iny
    jsr get_soft_collision
    bne +r

j:  inc has_collision
    jsr hit_brick
    bcs +r
    inc has_hit_brick

r:  rts
