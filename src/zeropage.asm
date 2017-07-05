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
foreground_collision: 0   ; Set if a sprite collision has been detected.

mode_laser      = 1
mode_catching   = 2
mode_disruption = 3
mode_extended   = 4
mode:                 0
mode_break:           0
current_bonus:        0

side_degrees:         0
caught_ball:          0
reflections_since_last_vaus_hit: 0
vaus_width:           0

level:                0
bricks_left:          0
bricks_until_bonus:   0
num_obstacles:        0

collision_y_distance: 0
collision_x_distance: 0

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
sfx_reflection:       0
snd_reflection:       0
old_paddle_value:     0
digisound_counter:    0 0

has_collision:        0                                                               
ball_x:               0
ball_y:               0

current_half:         0
bricks_in_line:       0

has_hit_brick:        0
has_hit_golden_brick: 0
has_hit_vaus:         0

laser_has_hit:        0   ; For the laser controller to remember if it hit one the left.

vaus_middle_idx:      0   ; Index of middle sprite of extended Vaus.

has_new_score:        0
has_hiscore:          0

score:      fill num_score_digits

sprites_x:          fill num_sprites  ; X positions.
sprites_y:          fill num_sprites  ; Y positions.
sprites_i:          fill num_sprites  ; Flags.
sprites_c:          fill num_sprites  ; Colors.
sprites_l:          fill num_sprites  ; Low character addresses.
sprites_fl:         fill num_sprites  ; Function controlling the sprite (low).
sprites_fh:         fill num_sprites  ; Function controlling the sprite (high).
sprites_dimensions: fill num_sprites  ; %0000rrcc
sprites_d:          fill num_sprites  ; Whatever the controllers want.

    @(check-zeropage-size (- #x00fc num_score_digits))
    org @(- #x00fc num_score_digits)

hiscore:    fill num_score_digits

    org $200

sprites_dx:     fill num_sprites ; Whatever the controllers want.
sprites_dy:     fill num_sprites ; Whatever the controllers want.
sprites_ox:     fill num_sprites ; Former X positions for cleaning up.
sprites_oy:     fill num_sprites ; Former Y positions for cleaning up.
sprites_width:  fill num_sprites ; Width in chars.
sprites_height: fill num_sprites ; Height in rows.

sprite_char:        0   ; Current sprite: First char.
sprite_x:           0   ; Current sprite: X position (text).
sprite_y:           0   ; Current sprite: Y position (text).
sprite_cols:        0   ; Current sprite: total width in chars.
sprite_inner_cols:  0   ; Current sprite: width in chars.
sprite_rows:        0   ; Current sprite: total height in chars.
sprite_inner_rows:  0   ; Current sprite: height in chars.
sprite_lines:       0   ; Current sprite: total height in lines.
sprite_inner_lines: 0   ; Current sprite: height in lines.
    end

; Minigrafik viewer
mg_s    = s
mg_d    = d
mg_c    = scr
