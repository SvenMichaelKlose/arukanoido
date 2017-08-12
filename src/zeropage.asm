    org 0
    data

s:                    0 0 ; Source pointer
d:                    0 0 ; Destination pointer
c:                    0 0 ; Counter

scr:                  0 0 ; Screen pointer (line start)
col:                  0 0 ; Colour RAM pointer
scrx:                 8   ; X position
scry:                 0   ; Y position
curchar:              0   ; Last allocated character
curcol:               0   ; Character colour

; VCPU
bcp:                  0 0
bca:                  0 0
num_args:             0
srx:                  0
a0:                   0
a1:                   0
a2:                   0
a3:                   0
a4:                   0

current_level:        0 0 ; Pointer to next level's data.

; Temporaries.
tmp:                  0
tmp2:                 0
tmp3:                 0
tmp4:                 0

; Temporary stores for index registers.
p_x:
add_sprite_x:         0
p_y:
add_sprite_y:
draw_sprite_x:        0
call_controllers_x:   0

next_sprite_char:     0   ; Next free character for sprites.
sprite_shift_y:       0   ; Number of character line where sprite starts.
sprite_data_top:      0   ; Start of sprite data in upper chars.
sprite_data_bottom:   0   ; Start of sprite data in lower chars.
sprite_height_top:    0   ; Number of sprite lines in upper chars.
spriteframe:          0   ; Character offset into lower or upper half of charset.
sprite_rr:            0   ; Round-robin sprite allocation index.

mode_laser      = 1
mode_catching   = 2
mode_disruption = 3
mode_extended   = 4
mode:                 0
mode_break:           0
current_bonus:        0

side_degrees:         0
caught_ball:          0
ball_release_timer:   0
vaus_width:           0
vaus_last_x:          0

level:                0
bricks_left:          0
num_obstacles:        0

joystick_status:      0

last_random_value:    0   ; Random number generator's last returned value.
framecounter:         0 0
lifes:                0
balls:                0

is_running_game:      0
has_moved_sprites:    0

ball_speed:           0
is_firing:            0   ; Laser interval countdown.
is_using_paddle:      0
old_paddle_value:     0
digisound_counter:    0 0

has_collision:        0                                                               
ball_x:               0
ball_y:               0

has_hit_brick:          0
has_hit_silver_brick:   0 ; TODO: Perhaps merge with has_golden_brick.
has_hit_golden_brick:   0
has_hit_vaus:           0
num_brick_hits:         0 ; Used to increase the ball speed.

score:      fill num_score_digits

sprites_x:          fill num_sprites  ; X positions.
sprites_y:          fill num_sprites  ; Y positions.
sprites_i:          fill num_sprites  ; Flags.
sprites_c:          fill num_sprites  ; Colors.
sprites_gl:         fill num_sprites  ; Low character addresses.
sprites_gh:         fill num_sprites  ; High character addresses.
sprites_fl:         fill num_sprites  ; Function controlling the sprite (low).
sprites_fh:         fill num_sprites  ; Function controlling the sprite (high).
sprites_dimensions: fill num_sprites  ; %0000rrcc
sprites_d:          fill num_sprites  ; Whatever the controllers want.

    @(check-zeropage-size (- #x00fc num_score_digits))
    org @(- #x00fc num_score_digits)

hiscore:    fill num_score_digits

    org $200

sprites_d2:     fill num_sprites ; Whatever the controllers want.
sprites_dx:     fill num_sprites ; Ball subpixel position
sprites_dy:     fill num_sprites
sprites_iw:     fill num_sprites ; Dimensions in chars.
sprites_ih:     fill num_sprites
sprites_w:      fill num_sprites ; Total dimensions in chars (after shift).
sprites_h:      fill num_sprites
sprites_sx:     fill num_sprites ; Screen position and dimensions in chars.
sprites_sy:     fill num_sprites
sprites_sw:     fill num_sprites
sprites_sh:     fill num_sprites
sprites_ox:     fill num_sprites ; Old screen position and dimensions in chars.
sprites_oy:     fill num_sprites
sprites_ow:     fill num_sprites
sprites_oh:     fill num_sprites

; Currently processed sprite
sprite_char:        0   ; First char.
sprite_x:           0   ; X position (text).
sprite_y:           0   ; Y position (text).
sprite_cols:        0   ; total width in chars.
sprite_inner_cols:  0   ; width in chars.
sprite_rows:        0   ; total height in chars.
sprite_inner_rows:  0   ; height in chars.
sprite_width:       0   ; Width in pixels.
sprite_lines:       0   ; total height in lines.
sprite_inner_lines: 0   ; height in lines.

laser_has_hit:        0   ; For the laser controller to remember if it hit one the left.
is_testing_laser_hit: 0
has_new_score:        0
has_hiscore:          0
scorechar_start:      0
next_powerup_score:   fill num_score_digits
score_silver:         fill num_score_digits

current_half:       0
scrx2:              0

has_removed_brick:      0
has_bonus_on_screen:    0

num_lifes_by_score:     0

has_paused:         0

    org $320

sprites_sf:     fill num_sprites
sprites_of:     fill num_sprites

brickfx_x:      fill num_sprites
brickfx_y:      fill num_sprites
brickfx_pos:    0
brickfx_end:    0

    end

; Minigrafik viewer
mg_s    = s
mg_d    = d
mg_c    = scr
