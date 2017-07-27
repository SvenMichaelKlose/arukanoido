control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_cone_init sprite_inits)
    jsr add_sprite
    tax
    lda #48        ; Direction
    sta sprites_d,x
    inc num_obstacles
done:
    rts

ctrl_obstacle:
    lda sprites_y,x
    cmp #24
    bcs +n

    ; Move obstacle in.
    inc sprites_y,x
r:  rts
n:

    ; Animate obstacle.
    lda framecounter
    and #7
    bne +n
    lda sprites_gl,x
    clc
    adc #16
    sta sprites_gl,x
    lda sprites_gh,x
    adc #0
    sta sprites_gh,x
    lda sprites_gl,x
    cmp #<gfx_obstacle_cone_end
    bne +n
    lda #<gfx_obstacle_cone
    sta sprites_gl,x
    lda #>gfx_obstacle_cone
    sta sprites_gh,x
n:

    jsr ball_step
    jsr reflect_obstacle
    lda has_collision
    beq +n
    jmp apply_reflection
n:  rts

; Y: Sprite index
remove_obstacle:
    txa
    pha
    tya
    tax
    jsr make_explosion
    dec num_obstacles
    lda #snd_hit_obstacle
    jsr play_sound
    pla
    tax
done:
    rts
