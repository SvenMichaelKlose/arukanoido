reflect_h:
    ; Bounce back left.
    lda sprites_d,x         ; Moving to the left?
    bpl +n                  ; No…
    ldy ball_x
    dey
    tya
    ldy ball_y
    cmp #7                  ; Avoid over-stepping the walls.
    bcc +m
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back right.
n:  ldy ball_x
    iny
    tya
    ldy ball_y
    cmp #@(++ (* 8 14))     ; Avoid over-stepping the walls.
    bcs +k
    jsr get_soft_collision
    bne +r
j:  lda #64
    jmp +l

m:  lda #7
    sta sprites_x,x
    jmp -j

k:  lda #@(* 8 14)
    sta sprites_x,x
    jmp -j

reflect:
    lda #0
    sta side_degrees
    sta has_collision

    jsr reflect_h

reflect_v:
    ; Bounce back top.
    lda sprites_d,x         ; Are we flying upwards?
    clc
    adc #64
    bpl +n                  ; No…
    lda ball_x
    ldy ball_y
    dey
    cpy #@(+ (* 8 playfield_yc) 7) ; Avoid over-stepping the walls.
    bcc +m
    jsr get_soft_collision
    bne +r
    beq +j

    ; Bounce back bottom.
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

m:  lda #@(+ (* 8 playfield_yc) 7)
    sta sprites_y,x
    jmp -j

apply_reflection:
    lda has_collision
    beq +r
apply_reflection_unconditionally:
    lda sprites_d,x     ; Get degrees.
    sec
    sbc side_degrees    ; Rotate back to zero degrees.
    jsr neg             ; Get opposite deviation from general direction.
    clc
    adc side_degrees    ; Rotate back to original axis.
    clc
    adc #128            ; Rotate to opposite direction.
    sta sprites_d,x
r:  rts
