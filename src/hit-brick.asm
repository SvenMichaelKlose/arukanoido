hit_doh:
    ldy test_offset
    lda (scr),y
    and #%01100000 ; Check on last quarter of chars in frame.
    cmp #%01100000
    bne +n
    lda #doh_flash_duration
    sta flashing_doh
    dec bricks_left
    clc
    rts

n:  sec
    rts

; Check if a brick has been hit.
;
; scr:         Screen base of brick to hit.
; test_offset: Screen offset of brick to hit.
;
; Returns:
; C=0: Regular or silver brick hit.
; C=1: No brick or golden brick hit.
hit_brick:
    lda #0
    sta has_removed_brick
    sta has_hit_silver_brick
    sta has_hit_golden_brick

    lda level
    cmp #doh_level
    beq -hit_doh

    ; Get pointer into 'bricks'.
    lda scr
    sta tmp
    lda @(++ scr)
    ora #>bricks
    sta @(++ tmp)

    ldy test_offset
    lda (tmp),y
    beq +no_brick_hit

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
    ldy test_offset
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
    inc removed_bricks

    ldy test_offset
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
    lda scrx
    sta removed_brick_x
    lda #0
    ldy test_offset
    sta (scr),y
    sta (tmp),y
    clc
    rts

golden:
    jsr add_brick_fx
    inc has_hit_golden_brick
no_brick_hit:
    sec
    rts
