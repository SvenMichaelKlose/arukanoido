;;; From arcade ROM (check code at 0x1442 and this table at 0x1462).
ball_speeds_when_top_hit:
    7 7 8 0 7 7 7 0 7 5
    7 7 8 6 7 5 7 7 7 0
    7 0 0 0 0 7 8 7 0 7
    0 0 0 0

;;; From arcade ROM.
ball_accelerations:
    $00 $19 $19 $23 $23 $2d $3c $50 $78 $8c $a0 $b4 $c8 $dc $f0

l:  inc acceleration_pending
    pla
    tay
    rts

;;; Adjust ball speed depending on number of collisions.
adjust_ball_speed:
    tya
    pha
    lda ball_speed
    cmp #$0f
    beq +r          ; Maximum ball speed already…

    inc num_hits

    lda acceleration_pending
    bne +n

    ;; Check if an increase is in order.
    lda ball_speed
    lsr
    tay
    lda num_hits
    cmp ball_accelerations,y
    bcc +r

    ;; Check if on bottom half of screen…
    lda sprites_y,x
    sec
    sbc arena_y
    cmp #@(* 8 14)
    bcc increase_ball_speed

    ;; …and delay acceleration if going downwards.
n:  lda sprites_d,x
    clc
    adc #64
    bpl -l

increase_ball_speed:
    lda #0
    sta acceleration_pending
    sta num_hits
    lda ball_speed
    ldy is_using_paddle
    bne +n
    cmp #max_ball_speed_joystick
    bcs +r
    bcc +l                  ; (jmp)
n:  cmp #max_ball_speed
    bcs +r                  ; Already at maximum speed. Do nothing…
l:  inc ball_speed          ; Play the blues…
r:  pla
    tay
    rts
