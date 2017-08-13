gfx_obstacles_gl:
    <gfx_obstacle_cone
    <gfx_obstacle_pyramid
    <gfx_obstacle_spheres
    <gfx_obstacle_cube

gfx_obstacles_gh:
    >gfx_obstacle_cone
    >gfx_obstacle_pyramid
    >gfx_obstacle_spheres
    >gfx_obstacle_cube

gfx_obstacles_gl_end:
    <gfx_obstacle_cone_end
    <gfx_obstacle_pyramid_end
    <gfx_obstacle_spheres_end
    <gfx_obstacle_cube_end

gfx_obstacles_gh_end:
    >gfx_obstacle_cone_end
    >gfx_obstacle_pyramid_end
    >gfx_obstacle_spheres_end
    >gfx_obstacle_cube_end

gfx_obstacles_c:
    cyan
    green
    white
    red

add_missing_obstacle:
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
    and #3
    tay
    lda gfx_obstacles_c,y
    sta sprites_c,x
    lda gfx_obstacles_gl,y
    sta sprites_gl,x
    lda gfx_obstacles_gh,y
    sta sprites_gh,x
done:
    rts

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

    ; Reset animation sequence when at end.
    ldy #3
l:  lda sprites_gl,x
    cmp gfx_obstacles_gl_end,y
    bne +n
    lda sprites_gh,x
    cmp gfx_obstacles_gh_end,y
    bne +n
    lda gfx_obstacles_gl,y
    sta sprites_gl,x
    lda gfx_obstacles_gh,y
    sta sprites_gh,x
    jmp +l
n:  dey
    bpl -l


; When nothing is touched, move downwards, do a circle.
; When touching something on the way down, go sideways.
; When touching something going sideways, try going up.
; When touching something going up, go back down but reverse sideways.
l:  jsr half_step_smooth

    lda sprites_y,x
    cmp #@(-- (* 8 screen_rows))
    bcc +n
    dec num_obstacles
    jmp remove_sprite

n:  lda #0
    sta obstacle_hit_obstacle
    ldy #@(-- num_sprites)
    jsr find_hit
    bcs +n
    bcc +l2
l:  jsr find_hit_next
    bcs +n
l2: lda sprites_i,y
    and #is_obstacle
    beq -l
    inc obstacle_hit_obstacle
n:

    lda sprites_x,x
    lsr
    lsr
    lsr
    sta scrx

    lda sprites_y,x
    lsr
    lsr
    lsr
    sta scry

    lda sprites_d,x
    bne +not_down       ; Not doing down.

    lda sprites_y,x
    and #7
    bne +r

    inc scry
    inc scry
    jsr get_hard_collision
    bne +r

    ldy #direction_left
    lda sprites_d2,x
    lsr
    bcc +n
    ldy #direction_right
n:  sty sprites_d,x
    rts

not_down:
    cmp #128
    bne +not_up

    dec scrx
    jsr get_hard_collision
    bne +r
    lda sprites_d2,x
    eor #1
    sta sprites_d2,x
l:  lda #direction_down
    sta sprites_d,x
r:  rts

not_up:
    lda sprites_x,x
    and #7
    bne +r

    inc scry
    inc scry
    jsr get_hard_collision
    bne -l
    dec scry
    dec scry

    lda sprites_d,x
    bpl +not_left

    dec scrx
    jsr get_hard_collision
    beq +f
    inc scry
    jsr get_hard_collision
    bne +r
f:  lda #direction_up
    sta sprites_d,x
r:  rts

not_left:
    inc scrx
    jsr get_hard_collision
    beq +f
    inc scry
    jsr get_hard_collision
    bne +r
f:  lda #direction_up
    sta sprites_d,x

r:  rts

obstacle_hit_obstacle:  0
