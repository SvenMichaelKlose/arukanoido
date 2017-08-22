hit_brick:
    lda #0
    sta has_removed_brick
    sta has_hit_silver_brick
    sta has_hit_golden_brick

    ; Get pointer into 'bricks'.
    lda scr
    sta tmp
    lda @(++ scr)
    ora #>bricks
    sta @(++ tmp)

    ldy scrx
    lda (tmp),y
    beq +r              ; No brick hit…

    pha
    lda is_testing_laser_hit
    bne +n
    jsr adjust_ball_speed
n:  pla
    inc has_hit_brick

    cmp #b_golden
    beq +golden
    bcc remove_brick
    inc has_hit_silver_brick
    cmp #b_silver
    beq remove_silver

    ; Degrade silver brick.
    ldy scrx
    lda (tmp),y
    sec
    sbc #1
    sta (tmp),y
    jsr add_brick_fx
    clc
    rts

    ; Silver brick's score is 50 multiplied by round number.
remove_silver:
    lda #<score_silver
    sta s
    lda #>score_silver
    sta @(++ s)
    jmp +o

remove_brick:
    ldy scrx
    lda (tmp),y
    tay
    lda brick_scores_l,y
    sta s
    lda brick_scores_h,y
    sta @(++ s)
o:  jsr add_to_score

    dec bricks_left
    inc has_removed_brick

    lda #0
    ldy scrx
    sta (scr),y
    sta (tmp),y
    clc
    rts

golden:
    jsr add_brick_fx
    inc has_hit_golden_brick
r:  sec
    rts
