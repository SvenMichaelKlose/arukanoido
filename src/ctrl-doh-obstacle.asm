add_missing_doh_obstacle:
    lda doh_wait
    beq +n
    dec doh_wait
    rts

    ; Add obstacle.
n:  ldy #@(- doh_obstacle_init sprite_inits)
    jsr add_sprite
    tax
    lda #56
    sta sprites_x,x
    lda #104
    sta sprites_y,x

    ; Aim at Vaus.
    ldy vaus_sprite_index
    lda sprites_x,y
    lsr
    sec
    sbc #26
    sta sprites_d,x

    ; Determine length of pause.
    inc num_doh_obstacles
    lda num_doh_obstacles
    cmp #5
    bne +n
    lda #@(* 24 5)
    sta doh_wait
    lda #0
    sta num_doh_obstacles
    rts

n:  lda #24
    sta doh_wait
    rts

ctrl_doh_obstacle:
    jsr half_step_smooth
    jsr half_step_smooth
    lda sprites_y,x
    cmp screen_height
    beq +l
    jsr half_step_smooth
    jsr half_step_smooth
    lda sprites_y,x
    cmp screen_height
    beq +l

n:  lda #is_vaus
    jsr find_hit
    bcs +a
    lda #0
    sta is_running_game
    lda #snd_miss
    jmp play_sound

l:  jmp remove_sprite

    ; Animate.
a:  lda framecounter
    and #7
    bne +r
    lda sprites_gl,x
    clc
    adc #8
    sta sprites_gl,x
    bcc +l
    inc sprites_gh,x

    ; Repeat animation.
l:  lda sprites_gl,x
    cmp #<gfx_obstacle_doh_end
    bne +r
    lda sprites_gh,x
    cmp #>gfx_obstacle_doh_end
    bne +r
    lda #<gfx_obstacle_doh
    sta sprites_gl,x
    lda #>gfx_obstacle_doh
    sta sprites_gh,x

r:  rts
