reflect:
    lda #0
    sta side_degrees
    sta has_collision

reflect_h:
    lda ball_x
    and #%111
    beq +o
    cmp #%111
    bne reflect_v

    ; Bounce back left.
o:  lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    ldy ball_x
    dey
    tya
    ldy ball_y
    jsr get_soft_collision
    beq reflect_v
    bne +j              ; (jmp)

    ; Bounce back right.
n:  ldy ball_x
    iny
    tya
    ldy ball_y
    jsr get_soft_collision
    beq reflect_v
j:  lda #64
    bne +l              ; (jmp)

reflect_v:
    lda ball_y
    and #%111
    beq +o
    cmp #%111
    bne +r

    ; Bounce back top.
o:  lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    lda ball_x
    ldy ball_y
    dey
    jsr get_soft_collision
    beq +r
    bne +j              ; (jmp)

    ; Bounce back bottom.
n:  lda ball_x
    ldy ball_y
    iny
    jsr get_soft_collision
    beq +r
j:  lda #128

l:  clc
    adc side_degrees
    sta side_degrees
    inc has_collision
    jmp hit_brick

apply_reflection:
    lda has_collision
    beq +r

apply_reflection_unconditionally:
    lda sprites_d,x     ; Get degrees.
    sec
    sbc side_degrees    ; Rotate back to zero degrees.
    eor #$ff            ; (neg) Get opposite deviation from general direction.
    sec
    adc side_degrees    ; Rotate back to original axis.
    eor #128            ; Rotate to opposite direction.
    sta sprites_d,x
r:  rts
