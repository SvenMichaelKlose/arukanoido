; 3x3 char offset table indexes.
;
; 0 1 2
; 7   3
; 6 5 4
b_nw    = 0
b_n     = 1
b_ne    = 2
b_e     = 3
b_se    = 4
b_s     = 5
b_sw    = 6
b_w     = 7

init_test_offsets:
    lda #<test_offsets
    sta d
    lda #>test_offsets
    sta @(++ d)
    lda #0
    jsr out_d
    lda #1
    jsr out_d
    lda #2
    jsr out_d
    lda screen_columns
    jsr out_d
    lda screen_columns
    clc
    adc #2
    jsr out_d
    lda screen_columns
    asl
    jsr out_d
    clc
    adc #1
    jsr out_d
    clc
    adc #1

out_d:
    ldy #0
    sta (d),y
inc_d:
    inc d
    bne +n
    inc @(++ d)
n:  rts

reflect:
    lda #0
    sta side_degrees
    sta has_collision

    ; Get screen position of char to the top left of the ball.
    ; 'test_offset' will be added to it via indirect indexing.
    lda ball_x
    lsr
    lsr
    lsr
    sta scrx        ; Keep ball's X char position.
    sta tmp2
    dec tmp2        ; Step left.
    lda ball_y
    lsr
    lsr
    lsr
    tay
    sty scry        ; Keep ball's Y char position.
    dey             ; Step up.
    ; Do a 'jsr scraddr' but also add the X position.
    lda line_addresses_l,y
    clc
    adc tmp2
    sta scr
    lda line_addresses_h,y
    adc #0
    sta @(++ scr)

reflect_h:
    ; Bounce back left.
    lda sprites_d,x     ; Moving to the left?
    bpl +n              ; No…

    ldy @(+ test_offsets b_w)   ; Test on brick west of ball.
    sty test_offset
    lda (scr),y
    and #foreground
    beq reflect_v
    bne +j              ; (jmp)

    ; Bounce back right.
n:  ldy @(+ test_offsets b_e)
    sty test_offset
    lda (scr),y
    and #foreground
    beq reflect_v
j:  lda #64
    bne +l              ; (jmp)

reflect_v:
    ; Bounce back top.
    lda sprites_d,x     ; Are we flying upwards?
    clc
    adc #64
    bpl +n              ; No…

    ldy @(+ test_offsets b_n)
    sty test_offset
    lda (scr),y
    and #foreground
    beq +r
    bne +j              ; (jmp)

    ; Bounce back bottom.
n:  ldy @(+ test_offsets b_s)
    sty test_offset
    lda (scr),y
    and #foreground
    beq +r

j:  lda #128

l:  clc
    adc side_degrees
    sta side_degrees
    inc has_collision
    jsr hit_brick
    bcs +r
    inc has_hit_brick
r:  rts

m:  lda arena_y
    sta sprites_y,x
    jmp -j

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
