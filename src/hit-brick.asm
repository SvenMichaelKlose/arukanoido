hit_doh:
    ldy scrx
    lda (scr),y
    and #%01100000
    cmp #%01100000
    bne +n
    dec bricks_left
    lda #snd_hit_doh
    jsr play_sound
    clc
    rts

n:  sec
    rts

hit_brick:
    lda #0
    sta has_removed_brick
    sta has_hit_silver_brick
    sta has_hit_golden_brick

    lda level
    cmp #33
    beq -hit_doh

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
    inc removed_bricks
    lda #<score_silver
    sta s
    lda #>score_silver
    sta @(++ s)
    jmp +o

remove_brick:
    inc removed_bricks

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

    lda scry
    sta removed_brick_y
    lda #0
    ldy scrx
    sty removed_brick_x
    sta (scr),y
    sta (tmp),y
    clc
    rts

golden:
    jsr add_brick_fx
    inc has_hit_golden_brick
r:  sec
    rts
