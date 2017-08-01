hit_brick:
    lda scr
    sta tmp
    lda @(++ scr)
    ora #>bricks
    sta @(++ tmp)

    ; Check brick type.
    ldy scrx
    lda (tmp),y
    beq +r              ; Not a brick of any type…
    cmp #b_golden
    beq +golden
    bcc remove_brick
    cmp #b_silver
    beq remove_silver

    lda #snd_reflection_silver
    sta snd_reflection

    ; Degrade silver brick.
    lda (tmp),y
    sec
    sbc #1
    jmp modify_brick

    ; Silver brick's score is 50 multiplied by round number.
remove_silver:
    txa
    pha
    ldx level
l:  lda #<score_50
    sta s
    lda #>score_50
    sta @(++ s)
    jsr add_to_score
    dex
    bne -l
    pla
    tax
    jmp +o

remove_brick:
    lda is_testing_laser_hit
    bne +n
    inc num_brick_hits
    jsr adjust_ball_speed
n:

    ldy scrx
    lda (tmp),y
    tay
    lda brick_scores_l,y
    sta s
    lda brick_scores_h,y
    sta @(++ s)
    jsr add_to_score

o:  dec bricks_left
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
    lda #snd_reflection_silver
    sta snd_reflection
r:  sec
    rts
