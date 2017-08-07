control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_cone_init sprite_inits)
    jsr add_sprite
    tax
    lsr
    bcs +n
    lda #@(+ 4 (* 10 8))
    sta sprites_x,x
n:  lda #direction_down
    sta sprites_d,x
    inc num_obstacles

    ldy level
    dey
    tya
    and #1
    bne +n
    lda #cyan
    sta sprites_c,x
    lda #<gfx_obstacle_cone
    ldy #>gfx_obstacle_cone
    jmp +l
n:  lda #red
    sta sprites_c,x
    lda #<gfx_obstacle_cube
    ldy #>gfx_obstacle_cube
l:  sta sprites_gl,x
    sty sprites_gh,x
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

    ; Animate.
    lda framecounter
    and #7
    bne +l
    lda sprites_gl,x
    clc
    adc #16
    sta sprites_gl,x
    bcc +m
    inc sprites_gh,x
m:

    lda sprites_gl,x
    cmp #<gfx_obstacle_cube_end
    bne +n
    lda sprites_gh,x
    cmp #>gfx_obstacle_cube_end
    bne +n
    lda #<gfx_obstacle_cube
    sta sprites_gl,x
    lda #>gfx_obstacle_cube
    sta sprites_gh,x
    jmp +l

n:  cmp #<gfx_obstacle_cone_end
    bne +n
    lda sprites_gh,x
    cmp #>gfx_obstacle_cone_end
    bne +n
    lda #<gfx_obstacle_cone
    sta sprites_gl,x
    lda #>gfx_obstacle_cone
    sta sprites_gh,x
n:

    ; Move.
l:  jsr ball_step
    jsr reflect_obstacle
    lda has_collision
    beq +n
    jsr turn_sprite

n:  ldy #@(-- num_sprites)
    jsr find_hit
    bcs +r
    bcc +l2
l:  jsr find_hit_next
    bcs +r
l2: lda sprites_i,y
    and #is_obstacle
    beq -l

turn_sprite:
    ; Step back in opposite direction.
    lda sprites_d,x
    clc
    adc #128
    sta sprites_d,x
    jsr ball_step

    ; Turn by 22.5°.
    txa
    lsr
    bcc +n
    lda #160        ; clockwise
    jmp +l
n:  lda #96         ; counterclockwise
l:  clc
    adc sprites_d,x
    sta sprites_d,x
r:  rts

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
    rts
