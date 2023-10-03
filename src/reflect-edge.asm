reflect_edge:
    lda #0
    sta side_degrees
    sta has_collision

    ; Bounce back from bottom right.
    lda sprites_d,x
    and #%11000000
    bne +n
    lda ball_x
    and ball_y
    and #%111
    cmp #%111
    bne +r
    ldy ball_x
    iny
    tya
    ldy ball_y
    iny
    jsr get_soft_collision
    beq +r
    bne +j

    ; Bounce back from top right.
n:  asl
    bcs +n
    lda ball_y
    and #%111
    bne +r
    lda ball_x
    and #%111
    cmp #%111
    bne +r
    ldy ball_x
    ldy ball_x
    iny
    tya
    ldy ball_y
    dey
    jsr get_soft_collision
    beq +r
    bne +j

    ; Bounce back from top left.
n:  asl
    bcs +n
    lda ball_y
    ora ball_y
    and #%111
    bne +r
    ldy ball_x
    dey
    tya
    ldy ball_y
    dey
    jsr get_soft_collision
    beq +r
    bne +j

    ; Bounce back from bottom left.
n:  lda ball_x
    and #%111
    bne +r
    lda ball_y
    and #%111
    cmp #%111
    bne +r
    ldy ball_x
    dey
    tya
    ldy ball_y
    iny
    jsr get_soft_collision
    beq +r

j:  inc has_collision
    jmp hit_brick

r:  rts
