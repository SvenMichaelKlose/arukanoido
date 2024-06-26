;;; Fixed addresses

screen          = $1000
decrunch_table  = $1250     ; 156 bytes
buffer_start_hi = $13
buffer_len_hi   = $01
charset         = $1400
bricks1         = $1c00     ; Map of brick types
bricks2         = $1e00
charset_addrs_l = $7e00
charset_addrs_h = $7f00
exm_buffers     = $be00     ; 2x256 bytes
colors          = $9400

txt_tmp         = bricks
preshifted_size = @(- charset_addrs_l the_end)

;;; Charset settings

num_chars           = 256
charsetsize         = @(* num_chars 8)

;;; Sprite/frame settings

num_sprites         = 8
framemask           = @(half num_chars)
framechars          = @(half num_chars)
first_sprite_char   = 1
foreground          = @(half framechars)
bg_start            = @(+ framechars foreground)
background          = @(half bg_start)
last_priority_char  = 4

;;; Game settings

default_num_lives       = 3

default_ball_speed      = 6
min_ball_speed          = 4
max_ball_speed          = 15
max_ball_speed_joystick = 6
max_ball_stickyness     = 64

ball_width              = 3
ball_height             = 5
laser_delay_short       = 9
laser_delay_long        = 20

delay_until_forced_release = $a0
delay_until_ball_is_released = $80

;;; Score settings

num_score_digits    = 6
score_char0         = 16    ; Digit '0' in 4x8 charset.

;;; Miscellaneous

num_brickfx         = 8     ; List of hit silver/golden bricks that
                            ; are being animated.
playfield_columns   = 15
vaus_x              = 52
doh_level           = 33
doh_flash_duration  = 3
num_demo_levels     = 10

;;; PAL

lives_on_screen     = @(+ (* 31 15) 1 screen)
lives_on_colors     = @(+ (* 31 15) 1 colors)
