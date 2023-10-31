;;; Indexes into tables

cone        = 0
pyramid     = 1
spheres     = 2
cube        = 3
none        = 255

used_obstacle_directions:
    @(byte (+ 128 direction_r))
    192
    direction_l
    direction_r
    64
    @(byte (+ 128 direction_l))
    0
used_obstacle_directions_end:

;;; Starts of animations
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

;;; Ends of animations
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

;;; Obstacle colours
gfx_obstacles_c:
    cyan
    green
    white
    red

;;; Obstacle types per level
level_obstacle:
    cone pyramid spheres cube cone
    pyramid spheres cube cone none
    spheres none cone pyramid spheres
    cube cone pyramid spheres cube
    cone pyramid spheres cube cone
    pyramid spheres cube cone pyramid
    spheres cube none

get_used_obstacle_direction:
    ldy #0
l:  cmp used_obstacle_directions,y
    beq +r
    iny
    cpy #@(- used_obstacle_directions_end used_obstacle_directions)
    bne -l
w:  jmp -w
r:  rts

turn_obstacle_clockwise:
    jsr get_used_obstacle_direction
    iny
    cpy #@(- used_obstacle_directions_end used_obstacle_directions)
    bne +l
    ldy #0
l:  lda used_obstacle_directions,y
    rts

turn_obstacle_counterclockwise:
    jsr get_used_obstacle_direction
    dey
    bpl -l
    ldy #@(- used_obstacle_directions_end used_obstacle_directions 1)
    bne -l  ; (jmp)

add_missing_obstacle:
    ldy level
    lda @(-- level_obstacle),y
    bmi +r                  ; No obstacles in level (none).
    lda num_obstacles
    cmp #3
    beq +r                  ; Three are enough.
    lda framecounter
    bne +r                  ; Only every 256 frames.

    inc do_animate_obstacle_gate
    lda #4
    sta obstacle_gate_frame

    ; Get X position.
    lda #3
    sta tmp
    ldy #@(+ 4 (* 3 8))
    jsr random
    lsr
    bcs +n
    lda #10
    sta tmp
    ldy #@(+ 4 (* 10 8))
n:  lda tmp
    sta new_obstacle_gate_xc
    sty new_obstacle_x

    inc num_obstacles

r:  rts

make_obstacle:
    ; Stop IRQ as we're dealing with the sprite tables
    ; outside of it.
    sei

    ldy #@(- obstacle_init sprite_inits)
    jsr add_sprite
    tax

    ; Set position.
    lda obstacle_y
    sta sprites_y,x
    lda new_obstacle_x
    sta sprites_x,x

    ; Set initial direction.
    lda #direction_down
    sta sprites_d,x
    jsr random
    and #128
    sta sprites_d2,x

    ; Set graphics.
    ldy level
    lda @(-- level_obstacle),y
    tay
    lda gfx_obstacles_c,y
    sta sprites_c,x
    lda gfx_obstacles
    sta sprites_pgl,x
    lda @(++ gfx_obstacles)
    sta sprites_pgh,x

    cli
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

animate_obstacle:
    ; Animate regular sprite every eigth frame.
    lda framecounter
    and #7
    bne +done

    lda has_3k
    ora has_24k
    bne +l2

    ; Animate regular sprite graphics
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
    jmp +r
n:  dey
    bpl -l
r:  rts

    ; Animate pre-shifted graphics.
l2:  lda sprites_pgl,x
    clc
    adc #@(* 8 30)
    sta sprites_pgl,x
    bcc +n
    inc sprites_pgh,x
n:  lda sprites_pgl,x
    cmp gfx_obstacles_end
    bne +done
    lda sprites_pgh,x
    cmp @(++ gfx_obstacles_end)
    bcc +done
    lda gfx_obstacles
    sta sprites_pgl,x
    lda @(++ gfx_obstacles)
    sta sprites_pgh,x

done:
    rts

ctrl_obstacle_move_in:
    jsr animate_obstacle
    lda sprites_y,x
    cmp arena_y
    bcs +n

    ; Move obstacle in.
    inc sprites_y,x
r:  rts

    ; Obstacle is out of its gate.
n:  lda #2  ; Tell to close gate.
    sta do_animate_obstacle_gate
    lda #<ctrl_obstacle_pacing
    ldy #>ctrl_obstacle_pacing

set_obstacle_controller:
    sta sprites_fl,x
    sty sprites_fh,x
    rts
 
ctrl_obstacle_circling:
    jsr animate_obstacle
    jsr decrement_counter
    jsr circling_obstacle
    jsr half_step_smooth
    jmp half_step_smooth

decrement_counter:
    ; Do it;
    lda sprites_d2,x
    and #%00011111
    tay
    dey
    bmi +l

    ; Store decremented counter.
    lda sprites_d2,x
    and #%11000000
    sta tmp
    tya
    ora tmp
    sta sprites_d2,x
    rts

    ; Wrap counter around.
l:  lda sprites_d2,x
    and #%11000000
    ora #%00111111
    sta sprites_d2,x
    rts

circling_obstacle:
    lda sprites_d2,x
    and #%00111111
    cmp #%00111111
    bne -r

n:  lda sprites_d2,x
    asl
    lda sprites_d,x
    bcs +n
    jsr turn_obstacle_counterclockwise
    sta sprites_d,x
    cmp #0
    bne +r
l:  lda #<ctrl_obstacle_chasing
    ldy #>ctrl_obstacle_chasing
    jmp set_obstacle_controller

n:  jsr turn_obstacle_clockwise
    sta sprites_d,x
    cmp #0
    beq -l
r:  rts

ctrl_obstacle_pacing:
    jsr animate_obstacle
    jsr pace_obstacle
    jmp half_step_smooth

pace_obstacle_again:
    sty sprites_d,x
pace_obstacle:
    ;; Check if obstacle left the level zone.
    ldy active_player
    dey
    lda level_ending_row,y
    asl
    asl
    asl
    sta tmp
    lda sprites_y,x
    sec
    sbc arena_y
    cmp tmp
    bcc +n          ; It didn't…

    ;; Start circling.
    lda sprites_x,x
    cmp #64
    bcs +m
    ; Counter-clockwise.
    lda #%01111111
    sta sprites_d2,x
    lda #@(+ 128 direction_l)
    sta sprites_d,x
k:  lda #<ctrl_obstacle_circling
    ldy #>ctrl_obstacle_circling
    jmp set_obstacle_controller
    ; Clockwise.
m:  lda #%11111111
    sta sprites_d2,x
    lda #@(+ 128 direction_r)
    sta sprites_d,x
    bne -k

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
    asl
    bcc +n
    ldy #direction_right
n:  jmp pace_obstacle_again

move_up:
    ; Move up?
    cmp #direction_up
    bne +move_horizontally

    ; Check on gap left or right.
    lda sprites_d2,x
    asl
    bcs +n

    jsr test_gap_left
    bcc +l
    dec sprites_x,x
m:  jmp pace_obstacle_again

n:  jsr test_gap_right
    bcc +l
    inc sprites_x,x
    bne -m

    ; Check collision upwards.
l:  jsr test_gap_top
    bcs +r
    lda sprites_d2,x
    eor #128
    sta sprites_d2,x
turn_downwards:
    ldy #direction_down
    jmp pace_obstacle_again

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
    bpl +move_right

    dec scrx
l:  jsr get_hard_collision
    bne +f
    inc scry
    jsr get_hard_collision
    beq +r
f:  ldy #direction_up
    jmp pace_obstacle_again
r:  rts

move_right:
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

ctrl_obstacle_chasing:
    ldy vaus_sprite_index
    lda sprites_x,y
    cmp sprites_x,x
    ldy #@(- 128 direction_l)
    bcc +n
    ldy #@(- 128 direction_r)
n:  tya
    sta sprites_d,x
    lda #<ctrl_obstacle_moving
    ldy #>ctrl_obstacle_moving
    jmp set_obstacle_controller

ctrl_obstacle_moving:
    jsr animate_obstacle
    jsr half_step_smooth
    jsr half_step_smooth
    lda sprites_y,x
    cmp screen_height
    bne -r
    dec num_obstacles
    jmp remove_sprite
