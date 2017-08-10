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
    inc num_brick_hits
    jsr adjust_ball_speed
n:  pla
    ldy scrx            ; TODO: Remove?

    cmp #b_golden
    beq +golden
    bcc remove_brick
    inc has_hit_silver_brick
    cmp #b_silver
    beq remove_silver

    ; Degrade silver brick.
    lda (tmp),y
    sec
    sbc #1
    jmp modify_brick

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

modify_brick:
    ldy scrx
    sta (tmp),y
    clc
    rts

golden:
    inc has_hit_golden_brick
r:  sec
    rts
