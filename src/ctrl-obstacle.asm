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
    ldy #@(- obstacle_init sprite_inits)
    jsr add_sprite
    tax
    lda #@(+ 4 (* 3 8))
    sta sprites_x,x
    lda arena_y
    sec
    sbc #7
    sta sprites_y,x
    jsr random
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
    cmp arena_y
    bcs +n

    ; Move obstacle in.
    inc sprites_y,x
r:  rts

    ; Animate.
n:  lda framecounter
    and #7
    bne +l2
    lda sprites_gl,x
    clc
    adc #16
    sta sprites_gl,x
    bcc +m
    inc sprites_gh,x

    ; Repeat animation.
m:  ldy #3
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
l2: jsr half_step_smooth

    ; Remove obstacle if it left the screen at the bottom.
    lda sprites_y,x
    cmp y_max
    bcc +n
    dec num_obstacles
    jmp remove_sprite

    ; Check if another obstacle was hit.
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

n:  jsr get_sprite_screen_position

    ; Skip testing vertical collision if not on Y char boundary.
    lda sprites_y,x
    and #7
    bne +not_up         ; No vertical movement to check.

    ; Move down.
    lda sprites_d,x
    bne +not_down       ; Not doing down.

    ; Test on collision at bottom.
    inc scry
    inc scry
    jsr get_hard_collision
    beq +f
    lda sprites_x,x
    and #7
    beq +r
    inc scrx
    jsr get_hard_collision
    bne +r

f:  ldy #direction_left
    lda sprites_d2,x
    lsr
    bcc +n
    ldy #direction_right
n:  sty sprites_d,x
r:  rts

not_down:
    ; Move up.
    cmp #direction_up
    bne +not_up

    ; Check collision upwards.
    dec scry
    jsr get_hard_collision
    beq +f
    lda sprites_x,x
    and #7
    beq +n
    inc scrx
    jsr get_hard_collision
    bne +n

f:  lda sprites_d2,x
    eor #1
    sta sprites_d2,x
turn_downwards:
    lda #direction_down
f:  sta sprites_d,x
r:  rts

    ; Check on gap left or right.
n:  lda sprites_d2,x
    lsr
    bcs +n

    ; Gap left?
    jsr get_sprite_screen_position
    dec scrx
    jsr get_hard_collision
    beq +r
    inc scry
    jsr get_hard_collision
    beq +r
    lda #direction_left
    sta sprites_d,x
r:  rts

    ; Gap right?
n:  jsr get_sprite_screen_position
    inc scrx
    jsr get_hard_collision
    beq +r
    inc scry
    jsr get_hard_collision
    beq +r
    lda #direction_right
    sta sprites_d,x
r:  rts

not_up:
    ; Skip testing horizontaal collision if not on Y char boundary.
    lda sprites_x,x
    and #7
    bne +r              ; No on char boundary.
    lda sprites_d,x
    ; Skip testing horizontal collision if direction is vertical.
    cmp #direction_up
    beq +r
    cmp #direction_down
    beq +r

    ; Move down if there is a gap.
    inc scry
    inc scry
    jsr get_hard_collision
    bne -turn_downwards
    dec scry
    dec scry

    ; Move left.
    lda sprites_d,x
    bpl +not_left

    dec scrx
l:  jsr get_hard_collision
    beq +f
    inc scry
    jsr get_hard_collision
    bne +r
f:  lda #direction_up
    sta sprites_d,x
r:  rts

not_left:
    ; Move right.
    inc scrx
    jmp -l

obstacle_hit_obstacle:  0
