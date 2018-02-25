; TODO: New movement rules
;
; * After dropping out of the game, Diagonally move half a char to the left or right.
; * On the upper half of the screen, move horizontally and vertically along tiles.
; * When hitting the bottom half of the screen, draw a circle to opposite side of the screen.
; * Move diagonally towards towards Vaus.
; * There varying delays when new obstacles drop in.

used_obstacle_directions:
    direction_l
    128
    direction_r
    64
    @(byte (+ 128 direction_l))
    0
    @(byte (+ 128 direction_r))
    192

get_used_obstacle_direction:
    ldy #7
l:  cmp used_obstacle_directions,y
    beq +r
    dey
    jmp -l
r:  rts

turn_obstacle_clockwise:
    jsr get_used_obstacle_direction
    iny
l:  tya
    and #7
    tay
    lda used_obstacle_directions,y
    rts

turn_obstacle_counterclockwise:
    jsr get_used_obstacle_direction
    dey
    jmp -l

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

cone        = 0
pyramid     = 1
spheres     = 2
cube        = 3
none        = 255

level_obstacle:
    cone pyramid spheres cube cone
    pyramid spheres cube cone none
    spheres none cone pyramid spheres
    cube cone pyramid spheres cube
    cone pyramid spheres cube cone
    pyramid spheres cube cone pyramid
    spheres cube none

add_missing_obstacle:
    ldy level
    dey
    lda level_obstacle,y
    bmi +done
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_init sprite_inits)
    jsr add_sprite
    tax
    lda arena_y
    sec
    sbc #7
    sta sprites_y,x
    lda #@(+ 4 (* 3 8))
    sta sprites_x,x
    jsr random
    lsr
    bcs +n
    lda #@(+ 4 (* 10 8))
    sta sprites_x,x
n:  lda #direction_down
    sta sprites_d,x
    jsr random
    and #1          ; Prefers left or right.
    sta sprites_d2,x
    inc num_obstacles

    ldy level
    dey
    lda level_obstacle,y
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
    ; Animate.
    lda framecounter
    and #7
    bne +m
    lda sprites_gl,x
    clc
    adc #16
    sta sprites_gl,x
    bcc +n
    inc sprites_gh,x

    ; Repeat animation.
n:  ldy #3
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
    jmp +m
n:  dey
    bpl -l

m:  lda sprites_y,x
    cmp arena_y
    bcs +n

    ; Move obstacle in.
    inc sprites_y,x
r2: rts
 
n:  jsr move_obstacle
    jmp half_step_smooth

move_obstacle_again:
    sty sprites_d,x
move_obstacle:
    ; Remove obstacle if it left the screen at the bottom.
    lda sprites_y,x
    cmp y_max
    bcc +n
    dec num_obstacles
    jmp remove_sprite

n:  lda sprites_d2,x
    and #2
    beq +pacing

circling:
    lda framecounter
    and #31
    bne +r

    lda sprites_d2,x
    lsr
    lda sprites_d,x
    bcs +n
    jsr turn_obstacle_counterclockwise
    sta sprites_d,x
    jmp +r
n:  jsr turn_obstacle_clockwise
    sta sprites_d,x
r:  lda sprites_d,x
    beq +m
    cmp #128
    beq -r2
    jsr half_step_smooth
    jsr half_step_smooth
    jmp -r2
m:  jsr half_step_smooth
    jsr half_step_smooth
r:  jsr half_step_smooth
    jmp half_step_smooth

pacing:
    lda level_bottom_y
    asl
    asl
    asl
    sta tmp
    lda sprites_y,x
    sec
    sbc arena_y
    cmp tmp
    bcc +n

    ; Start circling.
    lda sprites_x,x
    cmp #64
    bcs +m
    lda #2
    sta sprites_d2,x
    lda #@(+ 128 direction_l)
    sta sprites_d,x
    jmp -circling
m:  lda #3
    sta sprites_d2,x
    lda #@(+ 128 direction_r)
    sta sprites_d,x

    lda #255
    sta framecounter

    jmp -circling

n:  jsr get_sprite_screen_position

    ; Skip testing vertical collision if not on Y char boundary.
    lda sprites_y,x
    and #7
    bne +move_horizontally

    ; Move down?
    lda sprites_d,x
    bne +move_up

    jsr test_gap_bottom
    bcs +r

    ldy #direction_left
    lda sprites_d2,x
    lsr
    bcc +n
    ldy #direction_right
n:  jmp move_obstacle_again

move_up:
    ; Move up?
    cmp #direction_up
    bne +move_horizontally

    ; Check on gap left or right.
    lda sprites_d2,x
    lsr
    bcs +n

    jsr test_gap_left
    bcc +l
    dec sprites_x,x
m:  jmp move_obstacle_again

n:  jsr test_gap_right
    bcc +l
    inc sprites_x,x
    bne -m

    ; Check collision upwards.
l:  jsr test_gap_top
    bcs +r
    lda sprites_d2,x
    eor #1
    sta sprites_d2,x
turn_downwards:
    ldy #direction_down
    jmp move_obstacle_again

move_horizontally:
    ; Skip testing horizontaal collision if not on Y char boundary.
    lda sprites_x,x
    and #7
    bne +r              ; No on char boundary.

    lda sprites_d,x
    beq +r
    cmp #direction_up
    beq +r

    jsr test_gap_bottom
    bcs -turn_downwards

    ; Move left.
    jsr get_sprite_screen_position
    lda sprites_d,x
    bpl +not_left

    dec scrx
l:  jsr get_hard_collision
    bne +f
    inc scry
    jsr get_hard_collision
    beq +r
f:  ldy #direction_up
    jmp move_obstacle_again
r:  rts

not_left:
    ; Move right.
    inc scrx
    jmp -l

test_gap_left:
    jsr get_sprite_screen_position
    dec scrx
    jsr get_hard_collision
    bne +n
    inc scry
    jsr get_hard_collision
    bne +n
    ldy #direction_left
    sec
    rts
n:  clc
    rts

test_gap_right:
    jsr get_sprite_screen_position
    inc scrx
    jsr get_hard_collision
    bne -n
    inc scry
    jsr get_hard_collision
    bne -n
    ldy #direction_right
    sec
    rts

test_gap_bottom:
    jsr get_sprite_screen_position
    inc scry
    inc scry
l:  jsr get_hard_collision
    bne -n
    lda sprites_x,x
    and #7
    beq +f
    inc scrx
    jsr get_hard_collision
    bne -n
f:  sec
    rts

test_gap_top:
    jsr get_sprite_screen_position
    dec scry
    jmp -l
