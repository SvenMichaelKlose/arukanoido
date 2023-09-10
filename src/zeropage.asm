    org 0
    data

sl:
s:                    0   ; Source pointer
sh:                   0

dl:
d:                    0   ; Destination pointer
dh:                   0

cl:
c:                    0   ; Counter
ch:                   0

scr:                  0 0 ; Screen pointer (line start)
col:                  0 0 ; Colour RAM pointer
scrx:                 8   ; Screen char X position
scry:                 0   ; Screen char Y position
curchar:              0   ; Last allocated character
curcol:               0   ; Character colour

; VCPU
bcp:                  0 0
bca:                  0 0
num_args:             0
sra:                  0
srx:                  0
sry:                  0
a0:                   0
a1:                   0
a2:                   0
a3:                   0
a4:                   0
a5:                   0

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

side_degrees:         0

exo_x:                0
exo_y:                0
exo_y2:               0
exo_s:                0 0
exm_play_dptr:        0 0

framecounter:         0 0
digisound_counter:    0 0

has_collision:        0                                                               
ball_x:               0
ball_y:               0

scorechar_start:      0

; Currently processed sprite
sprite_char:            0   ; First char.
sprite_x:               0   ; X char position
sprite_y:               0   ; Y char position
sprite_cols:            0   ; Numer of columns.
sprite_cols_on_screen:  0   ; Numer of columns (+1 on shift).
sprite_rows:            0   ; Number of rows.
sprite_rows_on_screen:  0   ; Number of rows (+1 with offset line).
sprite_lines:           0
sprite_lines_on_screen: 0

sprites_i:          fill num_sprites  ; Flags.
sprites_x:          fill num_sprites  ; X positions.
sprites_y:          fill num_sprites  ; Y positions.
sprites_c:          fill num_sprites  ; Colors.
sprites_gl:         fill num_sprites  ; Low character addresses.
sprites_gh:         fill num_sprites  ; High character addresses.
sprites_fl:         fill num_sprites  ; Function controlling the sprite (low).
sprites_fh:         fill num_sprites  ; Function controlling the sprite (high).
sprites_dimensions: fill num_sprites  ; %00rrrccc (r = num rows, c = num cols).
sprites_d:          fill num_sprites  ; Whatever the controllers want.
sprites_pgl:        fill num_sprites  ; Pre-shifted graphics
sprites_pgh:        fill num_sprites

sprites_dx:     fill num_sprites ; Ball subpixel position
sprites_dy:     fill num_sprites
sprites_iw:     fill num_sprites ; Dimensions in chars.
sprites_ih:     fill num_sprites
sprites_w:      fill num_sprites ; Total dimensions in chars (after shift).
sprites_h:      fill num_sprites

score:      fill num_score_digits

; De-exomizer.
zp_src_hi:      0
zp_src_lo:      0
zp_src_bi:      0
zp_bitbuf:      0
zp_len_lo:      0 0
zp_bits_lo:     0
zp_bits_hi:     0
zp_dest_hi:     0
zp_dest_lo:     0
zp_dest_bi:     0

; Run-length audio decoder.
rle_val:        0
rle_cnt:        0
rle_bit:        0
rle_singles:    0
raw_play_ptr:
rle_play_ptr:   0 0

; No need to zero out the zero page from here on for a game restart.

uncleaned_zp:
user_screen_origin_x:   0
user_screen_origin_y:   0

; These do not have to be on page zero.
is_ntsc:                    0
is_landscape:               0
is_playing_digis:           0
currently_playing_digis:    0
has_ultimem:                0

zp_end:
    @(check-zeropage-size (- #x00fc num_score_digits))
    org @(- #x00fc num_score_digits)

hiscore:    fill num_score_digits

    org $200

sprites_d2:     fill num_sprites ; Whatever the controllers want.

; Screen position add dimensions in chars.  Even and odd positions
; are the two different frames.
sprites_sx:     fill @(* 2 num_sprites)
sprites_sy:     fill @(* 2 num_sprites)
sprites_sw:     fill @(* 2 num_sprites)
sprites_sh:     fill @(* 2 num_sprites)

laser_has_hit:        0   ; For the laser controller to remember if it hit one the left.
is_testing_laser_hit: 0

brickfx_x:      fill num_brickfx
brickfx_y:      fill num_brickfx
brickfx_pos:    0
brickfx_end:    0

next_powerup_score:   fill num_score_digits
score_silver:         fill num_score_digits

removed_brick_x:    0
removed_brick_y:    0

level:              0
bricks_left:        0
removed_bricks:     0
scrx2:              0
last_random_value:  0
exm_needs_data:     0

; TV standard dependant constants
format_params:
screen_columns:     0
double_screen_columns:  0
screen_rows:        0
vaus_y:             0
playfield_yc:       0
txt_hiscore_x:      0
txt_hiscore_y:      0
hiscore_x:          0
hiscore_y:          0
score_x:            0
score_y:            0
y_max:              0
screen_height:      0
arena_y:            0
arena_y_above:      0
xc_max:             0
yc_max:             0
ball_vaus_y_upper:  0
ball_vaus_y_above:  0
ball_vaus_y_lower:  0
ball_vaus_y_caught: 0
ball_max_x:         0
ball_max_y:         0
ball_min_y:         0
screen_gate:        0 0

; Temporaries

draw_bitmap_width:      0                                                                             
draw_bitmap_height:     0
draw_bitmap_num_chars:  0
draw_bitmap_y:          0
print_score_tmp:        0
find_hit_tmp:           0
find_hit_tmp2:          0
find_hit_tmp3:          0
find_hit_types:         0
draw_sprites_tmp:       0
draw_sprites_tmp2:      0
draw_sprites_tmp3:      0
print4x8_char:          0
make_stars_tmp:         0
music_tmp:              0
digisound_a:            0
digisound_x:            0
digisound_y:            0

apply_tmp:              0 0
vcpu_tmp:               0 0

line_addresses_l:       fill 33

get_crunched_byte_tmp:  0
attraction_mode:        0

if @*debug?*
next_bonus:             0
end

before_int_vectors:

    org $320

line_addresses_h:   fill 33
level_bottom_y:     0

lifes:              0
balls:              0

is_running_game:    0
has_moved_sprites:  0

current_bonus:      0
last_bonus:         0
caught_ball:        0
ball_release_timer: 0
vaus_width:         0
vaus_last_x:        0
ball_speed:         0
is_firing:          0       ; Laser interval countdown.
laser_delay_type:   0       ; 0: short, 1: long
old_paddle_value:   0       ; Used to detect paddles.
is_using_paddle:    0       ; Tells if paddles have been detected.

has_new_score:        0
has_hiscore:          0

has_removed_brick:      0
bonus_on_screen:        0
num_lifes_by_score:     0
has_paused:             0
has_hit_brick:          0
has_hit_silver_brick:   0
has_hit_golden_brick:   0
num_hits:               0 ; Used to increase the ball speed.

num_obstacles:          0
joystick_status:        0

; Position of pre-shifted sprite data.
preshifted_vaus:            0 0
preshifted_vaus_laser:      0 0
preshifted_vaus_extended:   0 0
preshifted_ball:            0 0
preshifted_ball_caught:     0 0
gfx_obstacles:              0 0
gfx_obstacles_end:          0 0

sprite_inits:           fill @sprite_inits_size

doh_wait:               0
num_doh_obstacles:      0
flashing_doh:           0

get_keypress_x:         0

vaus_sprite_index:      0

pagedptr:       0 0
new_direction:  0

test_offsets:
    0 0 0
    0   0
    0 0 0

test_offset:
    0

lowmem:
    end
