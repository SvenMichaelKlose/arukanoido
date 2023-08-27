add_missing_doh_obstacle:
    lda wait_doh_obstacles
    bne +r
    lda num_doh_obstacles
    cmp #5
    bcc +l
r:  rts

l:  lda framecounter
    and #15
    bne +r

    ldy #@(- doh_obstacle_init sprite_inits)
    jsr add_sprite
    pha
    jsr get_vaus_index_in_y
    pla
    tax
    lda sprites_x,y
    lsr
    sec
    sbc #26
    sta sprites_d,x
    lda #56
    sta sprites_x,x
    lda #104
    sta sprites_y,x
    inc num_doh_obstacles
    lda num_doh_obstacles
    cmp #5
    bne +r
    inc wait_doh_obstacles
r:  rts

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

l:
    jsr remove_sprite
    dec num_doh_obstacles
    bne +l
    dec wait_doh_obstacles
l:  rts

    ; Animate regular sprite.
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
    bne +n
    lda sprites_gh,x
    cmp #>gfx_obstacle_doh_end
    bne +n
    lda #<gfx_obstacle_doh
    sta sprites_gl,x
    lda #>gfx_obstacle_doh
    sta sprites_gh,x
    jmp +r
n:  dey
    bpl -l
r:  rts
