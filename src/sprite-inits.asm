sprite_init_flags       = 0
sprite_init_x           = 1
sprite_init_y           = 2
sprite_init_color       = 3
sprite_init_gfx_l       = 4
sprite_init_gfx_h       = 5
sprite_init_ctrl_l      = 6
sprite_init_ctrl_h      = 7
sprite_init_dimensions  = 8
sprite_init_data        = 9
sprite_init_pgl         = 10
sprite_init_pgh         = 11

is_inactive    = 128
is_doh_obstacle = 64
is_laser       = 16
is_ball        = 8
is_obstacle    = 4
is_bonus       = 2
is_vaus        = 1

multiwhite  = @(+ multicolor white)

loaded_sprite_inits:
    org sprite_inits

vaus_init:
    is_vaus
    0 0 @(+ 128 multiwhite)
    <gfx_vaus >gfx_vaus
    <ctrl_vaus >ctrl_vaus
    10 0 0 0
ball_init:
    is_ball
    0 0 white
    <gfx_ball >gfx_ball
    <ctrl_ball >ctrl_ball
    9 0 0 0
laser_init:
    is_laser
    0 0 yellow
    <gfx_laser >gfx_laser
    <ctrl_laser >ctrl_laser
    9 0 0 0
bonus_init:
    is_bonus
    0 0 0
    0 >gfx_bonus_l
    <ctrl_bonus >ctrl_bonus
    9 0 0 0
obstacle_init:
    is_obstacle
    0 0 0
    0 0
    <ctrl_obstacle_move_in >ctrl_obstacle_move_in
    17 0 0 0
doh_obstacle_init:
    is_doh_obstacle
    0 0 yellow
    <gfx_obstacle_doh >gfx_obstacle_doh
    <ctrl_doh_obstacle >ctrl_doh_obstacle
    9 0 0 0
sprite_inits_end:

sprite_inits_size = @(- sprite_inits_end sprite_inits)
    org @(+ loaded_sprite_inits sprite_inits_size)
