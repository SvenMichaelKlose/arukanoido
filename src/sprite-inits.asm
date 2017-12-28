sprite_init_x           = 0
sprite_init_y           = 1
sprite_init_flags       = 2
sprite_init_color       = 3
sprite_init_gfx_l       = 4
sprite_init_gfx_h       = 5
sprite_init_ctrl_l      = 6
sprite_init_ctrl_h      = 7
sprite_init_dimensions  = 8
sprite_init_data        = 9

is_inactive  = 128
was_cleared  = 64
is_laser     = 16
is_ball      = 8
is_obstacle  = 4
is_bonus     = 2
is_vaus      = 1

multiwhite  = @(+ multicolor white)

loaded_sprite_inits:
    org sprite_inits

vaus_init:      vaus_x vaus_y is_vaus     multiwhite <gfx_vaus >gfx_vaus    <ctrl_vaus >ctrl_vaus 10 0
ball_init:      0 0           is_ball     white      <gfx_ball >gfx_ball    <ctrl_ball >ctrl_ball 9 0
laser_init:     0 vaus_y      is_laser    yellow     <gfx_laser >gfx_laser  <ctrl_laser >ctrl_laser 9 0
bonus_init:     0 0           is_bonus    black      0 >gfx_bonus_l         <ctrl_bonus >ctrl_bonus 9 0
obstacle_init:  0 0           is_obstacle cyan       0 0                    <ctrl_obstacle >ctrl_obstacle 17 0
sprite_inits_end:

sprite_inits_size = @(- *pc* sprite_inits)
    org @(+ loaded_sprite_inits sprite_inits_size)
