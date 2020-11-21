; Fixed addresses

screen          = $1000
buffer_start_hi = $13
buffer_len_hi   = $01
charset         = $1400
bricks          = $1c00
txt_tmp         = bricks
exm_buffers     = $1e00
colors          = $9400

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
default_ball_speed      = 5

min_ball_speed          = 2
max_ball_speed          = 16
max_ball_speed_joystick = 6
max_ball_speed_joystick_top = 6

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

num_brickfx         = 16
playfield_columns   = 15

vaus_x              = 52

; PAL

lifes_on_screen     = @(+ (* 31 15) 1 screen)
lifes_on_colors     = @(+ (* 31 15) 1 colors)
