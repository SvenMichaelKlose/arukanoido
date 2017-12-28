; Fixed addresses

music_player = $7000
bricks       = $1c00

; VIC settings

screen              = $1000
line_addresses_l    = $1300
line_addresses_h    = $1330
charset             = $1400
colors              = $9400

; Charset settings

num_chars           = 256
charsetsize         = @(* num_chars 8)

; Sprite/frame settings

num_sprites         = 8
charsetmask         = @(-- num_chars)
framemask           = @(half num_chars)
framechars          = @(half num_chars)
first_sprite_char   = 1
foreground          = @(half framechars)
bg_start            = @(+ framechars foreground)

; Ball directions

deg_steep   = 20
deg_shallow = 41
direction_ls    = @(+ 128 deg_shallow)
direction_l     = @(+ 128 deg_steep)
direction_r     = @(- 128 deg_steep)
direction_rs    = @(- 128 deg_shallow)

; Game settings

default_num_lifes       = 3
default_ball_speed      = 3
min_ball_speed          = 2
max_ball_speed          = 7
max_ball_speed_joystick = 3
max_ball_speed_joystick_top = 4
default_ball_direction          = direction_r
default_ball_direction_skewed   = direction_rs
ball_width              = 3
ball_height             = 5
vaus_edge_distraction   = 16
laser_delay_short       = 9
laser_delay_long        = 20

initial_delay_until_ball_is_released = $a0
delay_until_ball_is_released = $80

; Score settings

num_score_digits    = 7
score_char0         = 16    ; Digit '0' in 4x8 charset.

; Miscellaneous

num_brickfx     = 24

; PAL
if @(eq *tv* :pal)
c_screen_columns    = 15
screen_rows         = 32
screen_origin_x     = 20
screen_origin_y     = 21
txt_round_nn_y      = 22
vaus_y              = @(* 29 8)
playfield_yc        = 2
txt_hiscore_x       = 10
txt_hiscore_y       = 0
hiscore_x           = 12
hiscore_y           = 1
score_x             = 0
score_y             = 1
end

; NTSC
if @(eq *tv* :ntsc)
c_screen_columns    = 21
screen_rows         = 28
screen_origin_x     = 5
screen_origin_y     = 16
txt_round_nn_y      = 20
vaus_y              = @(* 27 8)
playfield_yc        = 0
txt_hiscore_x       = 31
txt_hiscore_y       = 2
hiscore_x           = 33
hiscore_y           = 3
score_x             = 33
score_y             = 1
end

vaus_x              = 52
screen_width        = @(* c_screen_columns 8)
screen_height       = @(* screen_rows 8)
screen_playfield    = @(+ screen (* playfield_yc c_screen_columns))
screen_gate0        = @(+ screen (* c_screen_columns (+ playfield_yc 26)) 14)
screen_gate1        = @(+ screen (* c_screen_columns (+ playfield_yc 27)) 14)
screen_gate2        = @(+ screen (* c_screen_columns (+ playfield_yc 28)) 14)
lifes_on_screen     = @(+ (* 31 c_screen_columns) 1 screen)                                                 
lifes_on_colors     = @(+ (* 31 c_screen_columns) 1 colors)
screen_round        = @(+ screen (* c_screen_columns txt_round_nn_y) 5)
screen_ready        = @(+ screen (* c_screen_columns (+ txt_round_nn_y 2)) 6)
xc_max              = @(-- c_screen_columns)
yc_max              = @(-- screen_rows)
x_max               = @(-- screen_width)
y_max               = @(-- screen_height)
ball_vaus_y_upper   = @(- vaus_y ball_height)
ball_vaus_y_above   = @(-- ball_vaus_y_upper)
ball_vaus_y_lower   = @(+ vaus_y 8)
ball_vaus_y_caught  = @(- vaus_y 8)
ball_max_x          = @(-- (* (-- c_screen_columns) 8))
ball_max_y          = @(- (* 8 (+ playfield_yc 30)) 2)
ball_min_y          = @(- (* (++ playfield_yc) 8) 2)
arena_y             = @(* (++ playfield_yc) 8)
arena_y_above       = @(+ (* 8 playfield_yc) 7)
