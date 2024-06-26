    org 0
    data

;;; Block pointers
sl:
s:          0   ; Source pointer
sh:         0

dl:
d:          0   ; Destination pointer
dh:         0

cl:
c:          0   ; Counter
ch:         0

;;; Temporaries
tmp:        0
tmp2:       0
tmp3:       0
tmp4:       0
tmp5:       0
tmp6:       0
ctrl_ball_tmp: 0

;;; Screen access
scr:        0 0 ; Screen pointer (line start)
col:        0 0 ; Colour RAM pointer
scrx:       8   ; Screen char X position
scry:       0   ; Screen char Y position
curchar:    0   ; Last allocated character
curcol:     0   ; Character colour

;;; Brick map
brickp:     0 0

;;; Printing text
scrx2:      0

;;; VCPU
bcp:        0 0
bca:        0 0
num_args:   0
sra:        0
srx:        0
sry:        0
a0:         0
a1:         0
a2:         0
a3:         0
a4:         0

;;; Global state
framecounter:         0 0

;;; Sprites
draw_sprite_x:          0
next_sprite_char:       0 ; Next free character for sprites.
spriteframe:            0 ; Character offset into lower or upper half of charset.
sprite_char:            0 ; First char.
sprite_x:               0 ; X position
sprite_y:               0 ; Y position
sprite_scrx:            0 ; X char position
sprite_scry:            0 ; Y char position
sprite_cols:            0 ; Numer of columns.
sprite_cols_on_screen:  0 ; Numer of columns (+1 on shift).
sprite_rows:            0 ; Number of rows.
sprite_rows_on_screen:  0 ; Number of rows (+1 with offset line).
sprite_lines:           0 ; Number of lines.
sprite_lines_on_screen: 0 ;
;; Statically initialised (keep order)
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
;; Computed.
sprites_pgl:        fill num_sprites  ; Pre-shifted graphics.
sprites_pgh:        fill num_sprites
sprites_d2:         fill num_sprites  ; Whatever the controllers want.
sprites_dx:         fill num_sprites  ; Ball subpixel position.
sprites_dy:         fill num_sprites
sprites_iw:         fill num_sprites  ; Dimensions in chars.
sprites_ih:         fill num_sprites

sprites_sw:         fill @(* 2 num_sprites)

;;; Ball
ball_x:               0
ball_y:               0
has_reflection:        0

;;; Reflection
side_degrees:         0

;;; Decompression
get_crunched_byte_tmp:  0
;; Exomizer
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

;;; Digisound players
if @*has-digis?*
currently_playing_digis: 0
exm_needs_data: 0
digisound_a:
paddle_nmi_a:   0
digisound_x:    0
digisound_y:
paddle_nmi_y:   0
raw_play_ptr:
rle_play_ptr:
exm_play_ptr:   0 0 0
exm_play_dptr:  0 0
end
if @(not *has-digis?*)
paddle_nmi_a:   0
paddle_nmi_y:   0
end
rle_cnt:
exo_y:          0
rle_val:
exo_x:          0
rle_singles:
exo_s:          0 0
rle_bit:
exo_y2:         0

score:          0 0

;;; Obstacles
do_animate_obstacle_gate: 0
obstacle_gate_frame:      0
new_obstacle_gate_xc:     0
new_obstacle_x:           0

is_doh_level:   0

uncleaned_zp:

bricks:         0   ; Starting page of brick map.
hiscore:    fill num_score_digits

zp_end:
    @(check-zeropage-size #x00fc)
    org @(- #x00fc num_score_digits)

    org $200

last_random_value:  0

;;; Sprites
;; Screen position add dimensions in chars.  Even and odd positions
;; are the two different frames.
sprites_sx:     fill @(* 2 num_sprites)
sprites_sy:     fill @(* 2 num_sprites)
sprites_sh:     fill @(* 2 num_sprites)
;; Temporaries
call_controllers_x:     0
position_has_changed:   0

;;; Printing text
p_x:            0
p_y:            0
;print4x8_char:  0

if @*brickfx?*
;;; Brick FX
;; Circular list of bricks to animate.
brickfx_x:      fill num_brickfx
brickfx_y:      fill num_brickfx
brickfx_pos:    0   ; First.
brickfx_end:    0   ; Last.
end

;;; Scores
num_lives_by_score: 0
next_powerup_score: fill num_score_digits
score_silver:       fill num_score_digits
has_new_score:      0
has_hiscore:        0
score1:             fill num_score_digits
score2:             fill num_score_digits

;;; Drawing scores
score1_char_start:    0
hiscore_char_start:   0
score2_char_start:    0

;;; TV standard dependant constants
;; static
format_params:
screen_columns: 0
screen_rows:    0
vaus_y:         0
playfield_yc:   0
txt_1up_x:      0
txt_1up_y:      0
score1_x:       0
score1_y:       0
txt_hiscore1_x: 0
txt_hiscore1_y: 0
hiscore1_x:     0
hiscore1_y:     0
txt_2up_x:      0
txt_2up_y:      0
score2_x:       0
score2_y:       0
color_1up:      0 0
color_2up:      0 0
;; computed
double_screen_columns:  0
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
ball_max_y:         0
ball_min_y:         0
screen_gate:        0 0

;;; Compressed bitmaps
draw_bitmap_width:      0                                                                             
draw_bitmap_height:     0
draw_bitmap_num_chars:  0
draw_bitmap_y:          0

;;; VCPU
apply_tmp:  0 0
vcpu_tmp:   0 0

;;; Game state
is_running_game:    0
has_paused:         0
lives1:             0
lives2:             0
balls:              0
;;; Modes
attraction_mode:    0
;; Game mode
mode_laser      = 1
mode_catching   = 2
mode_disruption = 3
mode_extended   = 4
mode:               0
mode_break:         0
gate_opening:       0
;; Level
level_starting_row: 0 0
level_ending_row:   0 0
level:              0 0 0
bricks_left:        0 0
;; Ball
caught_ball:            0
ball_release_timer:     0
ball_speed:             0
num_hits:               0
acceleration_pending:   0
;; Vaus
vaus_width:         0
vaus_last_x:        0
vaus_sprite_index:  0
;; Bonus
removed_bricks_for_bonus:   0
hits_before_bonus:  0
has_missed_bonus:   0
active_bonus:       0
last_bonus:         0
bonus_is_dropping:  0
if @*debug?*
next_bonus:         0
end
;; Laser
is_firing:          0       ; Laser interval countdown.
laser_delay_type:   0       ; 0: short, 1: long
laser_has_hit:      0
;; Obstacles
obstacle_release_countdown: 0
num_obstacles:              0
; Start and end of current obstacle graphics.
gfx_obstacles:      0 0
gfx_obstacles_end:  0 0
;; DOH
doh_wait:           0
num_doh_obstacles:  0
flashing_doh:       0

;;; Brick collisions
is_testing_laser_hit:   0
has_removed_brick:      0
has_hit_brick:          0
has_hit_silver_brick:   0
has_hit_golden_brick:   0
removed_brick_x:        0
removed_brick_y:        0

;;; Redrawing
has_moved_sprites:       0
delay_redrawing:         0
needs_redrawing_lives:   0
needs_redrawing_score1:  0
needs_redrawing_score2:  0
needs_redrawing_hiscore: 0
overkill:                0

;;; Paddles
is_using_paddle:        0 ; Tells if paddles have been detected.
paddle_value:           0
old_paddle_value:       0
paddle_move_distance:   0

; Position of pre-shifted sprite data.
preshifted_vaus:            0 0
preshifted_vaus_laser:      0 0
preshifted_vaus_extended:   0 0
preshifted_ball:            0 0
preshifted_ball_caught:     0 0

;;; Keyboard
get_key_x:         0

;;; Top-level
current_toplevel_view:  0
hiscore_player:         0

pal_raster_correction:  0

before_int_vectors:

    org $320

line_addresses_l = $100 ;:   fill 33
line_addresses_h:   fill 33

; For 'add_sprite'.
sprite_inits:           fill @sprite_inits_size
free_sprites:           fill @(++ num_sprites)

init_bonus_d_direction:     0
init_bonus_d_balls_to_add:  0

uncleaned_lowmem:

user_screen_origin_x:   0
user_screen_origin_y:   0
obstacle_y:             0
is_ntsc:                0
is_landscape:           0

has_ultimem:        0
has_3k:             0
has_24k:            0
has_digis:          0
if @*has-digis?*
is_playing_digis:   0
end

;;; Game configuration
;; Players
has_two_players:    0
active_player:      0

lo_x:       0
lo_yx:      0
lo_mx:      0
lo_ymx:     0
lo_2y:      0

scratch:    "                          "
lowmem:
    end
