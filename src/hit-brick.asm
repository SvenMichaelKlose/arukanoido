hit_doh:
    ldy scrx
    lda (scr),y
    and #%01100000 ; Check if background char.
    cmp #%01100000
    bne +r
    lda #doh_flash_duration
    sta flashing_doh
    txa
    ldx active_player
    dec @(-- bricks_left),x
    tax
r:  rts

;;; Check if a brick has been hit.
;;; Ball MUST have been reflected by something.
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

    ;; Check if off brick map.
    lda scry
    sec
    sbc playfield_yc
    cmp #24
    bcs -r

    ;; Redirect to DOH handling.
    lda is_doh_level
    bne -hit_doh

    ;; Check if any type of brick has been hit.
    ; Get pointer into brick map as we cannot tell from screen chars.
    lda scr
    sta brickp
    lda @(++ scr)
    ora bricks
    sta @(++ brickp)
    ldy scrx
    lda (brickp),y
    beq +no_brick_hit

    ;; Adjust ball speed but not for laser hits.
    ldy is_testing_laser_hit
    bne +n
    jsr adjust_ball_speed
n:  inc has_hit_brick           ; (Set flag.)

    ldy scrx
    lda (brickp),y

    ;; Dispatch for regular, silver and golden bricks.
    cmp #b_golden
    beq +golden
    bcc remove_brick            ; Regular brick…
    inc has_hit_silver_brick    ; (Set flag.)
    cmp #b_silver
    beq remove_silver

    ;; Degrade silver brick.
    sec
    sbc #1
    sta (brickp),y
    inc has_hit_brick
    jmp add_brick_fx

    ;; Remove fully degraded silver brick.
remove_silver:
    ; Silver brick's score is 50 multiplied by round number.
    lda #<score_silver
    sta sl
    lda #>score_silver
    sta sh
    bne +o  ; (jmp)

    ;; Remove regular brick.
remove_brick:
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
    lda (brickp),y
    tay
    lda brick_scores_l,y
    sta sl
    lda brick_scores_h,y
    sta sh
o:  jsr add_to_score

    ;; Count removed brick.
    txa
    pha
    ldx active_player
    dec @(-- bricks_left),x
    pla
    tax
    inc has_removed_brick   ; (Set flag.)

    ;; Vanish brick from screen and brick map.
    lda scry
    sta removed_brick_y
    lda #0
    ldy scrx
    sty removed_brick_x
    sta (scr),y
    sta (brickp),y

    inc has_hit_brick       ; (Set flag.)
no_brick_hit:
    rts

    ;; Handle golden brick.
golden:
    inc has_hit_golden_brick    ; (Set flag.)
    jmp add_brick_fx
