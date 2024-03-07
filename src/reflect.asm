reflect:
    lda #0
    sta side_degrees
    sta has_reflection

reflect_h:
    lda ball_x
    and #%111
    beq +o
    cmp #%111
    beq +n
    bne reflect_v

    ; Bounce back left.
o:  lda sprites_d,x         ; Moving to the left?
    bpl +reflect_v          ; No…
    ldy ball_x
    dey
    tya
    ldy ball_y
    jsr get_soft_collision
    beq +reflect_v
    lda #64
    bne +l ; (jmp)

    ; Bounce back right.
n:  lda sprites_d,x         ; Moving to the right?
    bmi +reflect_v          ; No…
    ldy ball_x
    iny
    tya
    ldy ball_y
    jsr get_soft_collision
    beq +reflect_v
    lda #64
    bne +l ; (jmp)

reflect_v:
    lda ball_y
    and #%111
    beq +o
    cmp #%111
    beq +n
    bne +r

    ; Bounce back top.
o:  lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    ldy ball_y
    dey
    cpy arena_y_above
    beq +m                  ; Reflect from open obstacle gate…
    lda ball_x
    jsr get_soft_collision
    beq +r
    lda #128
    bne +l ; (jmp)
m:  jsr scraddr
    jmp +j

    ; Bounce back bottom.
n:  lda sprites_d,x         ; Are we flying downwards?
    clc
    adc #64
    bmi +r                  ; No…
    lda ball_x
    ldy ball_y
    iny
    jsr get_soft_collision
    beq +r
j:  lda #128

l:  sta side_degrees
    inc has_reflection
    jmp hit_brick

apply_reflection:
    lda has_reflection
    beq +r

apply_reflection_unconditionally:
    jsr adjust_ball_speed
    lda sprites_d,x     ; Get degrees.
    sec
    sbc side_degrees    ; Rotate back to zero degrees.
    eor #$7f            ; (neg) Get opposite deviation from general direction.
    sec                 ; TODO: Remove?
    adc side_degrees    ; Rotate back to original axis.
    ;eor #128            ; Rotate to opposite direction.
    sta sprites_d,x
r:  rts
