hit_brick:
    ; Check brick type.
    ldy scrx
    lda (scr),y
    cmp #bg_brick_special4
    bcs +r              ; Not a brick of any type…
    cmp #bg_brick_special1
    beq check_golden_brick
    cmp #bg_brick_orange
    bcc +r              ; Not a brick of any type…
    beq remove_brick
    cmp #bg_brick
    beq remove_brick

    lda #snd_reflection_silver
    sta snd_reflection

    ; Degrade silver brick.
    lda (scr),y
    sec
    sbc #1
    jmp modify_brick

check_golden_brick:
    lda (col),y
    and #$0f
    cmp #yellow
    beq +golden

    ; Silver brick's score is 50 multiplied by round number.
    txa
    pha
    ldx level
l:  ldy #@(- score_50 scores)
    jsr add_to_score
    dex
    bne -l
    pla
    tax
    jmp +o

remove_brick:
    inc num_brick_hits
    jsr adjust_ball_speed

    lda (col),y
    and #$0f
    tay
    lda color_scores,y
    tay
    jsr add_to_score
o:  dec bricks_left
    lda #0
    ldy scrx
modify_brick:
    sta (scr),y
    clc
    rts

golden:
    inc has_hit_golden_brick
    lda #snd_reflection_silver
    sta snd_reflection
r:  sec
    rts
