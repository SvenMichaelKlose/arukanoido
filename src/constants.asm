; Fixed addresses

music_player = $7000
bricks       = $1200

; VIC settings

screen       = $1000
charset      = $1400
colors       = $9400

; Screen settings

screen_columns  = 15
screen_rows     = 32
screen_width    = @(* screen_columns 8)
screen_height   = @(* screen_rows 8)

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
max_ball_speed          = 6
max_ball_speed_joystick = 3
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
