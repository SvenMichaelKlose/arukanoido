hit_doh:
    ldy scrx
    lda (scr),y
    and #%01100000 ; Check if background char.
    cmp #%01100000
    bne +n
    lda #doh_flash_duration
    sta flashing_doh
    dec bricks_left
n:  rts

;;; Check if a brick has been hit.
;;;
;;; scr: Screen address of brick to hit.
;;;
;;; Returns:
;;; C=0: Regular or silver brick hit.
;;; C=1: No brick or golden brick hit.
hit_brick:
    ;; Reset flags other parts of the game want to know about.
    lda #0
    sta has_removed_brick
    sta has_hit_brick
    sta has_hit_silver_brick
    sta has_hit_golden_brick

    ;; Redirect to DOH handling.
    lda level
    cmp #doh_level
    beq -hit_doh

    ;; Check if any type of brick has been hit.
    ; Get pointer into brick map as we cannot tell from screen chars.
    lda scr
    sta tmp
    lda @(++ scr)
    ora bricks
    sta @(++ tmp)

    ; Check.
    ldy scrx
    lda (tmp),y
    beq +no_brick_hit

    ;; Adjust ball speed but not for laser hits.
    pha
    lda is_testing_laser_hit
    bne +n
    jsr adjust_ball_speed
n:  pla
    inc has_hit_brick           ; (Set flag.)

    ;; Dispatch for regular, silver and golden bricks.
    cmp #b_golden
    beq +golden
    bcc remove_brick
    inc has_hit_silver_brick    ; (Set flag.)
    cmp #b_silver
    beq remove_silver

    ;; Degrade silver brick.
    ldy scrx
    lda (tmp),y
    sec
    sbc #1
    sta (tmp),y
    jsr add_brick_fx
    inc has_hit_brick
    rts

    ;; Remove fully degraded silver brick.
remove_silver:
    ; Silver brick's score is 50 multiplied by round number.
    lda #<score_silver
    sta s
    lda #>score_silver
    sta @(++ s)
    bne +o  ; (jmp)

    ;; Remove regular brick.
remove_brick:
    ; Keep track of removed bricks for so we know when
    ; we have to create a bonus.
    lda bonus_is_dropping
    ora has_missed_bonus
    ora has_hit_silver_brick
    ora is_testing_laser_hit
    bne +n
    lda mode
    cmp #mode_disruption
    beq +n
    inc removed_bricks_for_bonus
n:
    ; Add score of brick.
    ldy scrx
    lda (tmp),y
    tay
    lda brick_scores_l,y
    sta s
    lda brick_scores_h,y
    sta @(++ s)
o:  jsr add_to_score

    ;; Keep track of removed bricks,
    dec bricks_left
    inc has_removed_brick   ; (Set flag.)

    ;; Vanish brick from screen and brick map.
    lda scry
    sta removed_brick_y
    lda #0
    ldy scrx
    sty removed_brick_x
    sta (scr),y
    sta (tmp),y

    inc has_hit_brick       ; (Set flag.)
    rts

    ;; Handle golden brick.
golden:
    jsr add_brick_fx
    inc has_hit_golden_brick    ; (Set flag.)
no_brick_hit:
    rts
