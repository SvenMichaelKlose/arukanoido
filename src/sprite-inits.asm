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
is_ball      = 8
is_obstacle  = 4
is_bonus     = 2
is_vaus      = 1

vaus_y      = @(* 29 8)
multiwhite  = @(+ multicolor white)

sprite_inits:
vaus_init:
    52 vaus_y is_vaus     multiwhite <gfx_vaus >gfx_vaus    <ctrl_vaus >ctrl_vaus 10 0
ball_init:
    0 0       is_ball     white      <gfx_ball >gfx_ball    <ctrl_ball >ctrl_ball 9 0
laser_init:
    0 vaus_y  0           yellow     <gfx_laser >gfx_laser  <ctrl_laser >ctrl_laser 9 0
bonus_init:
    0 0       is_bonus    black      0 >gfx_bonus_l         <ctrl_bonus >ctrl_bonus 9 0
obstacle_cube_init:
    28 12     is_obstacle purple      <gfx_obstacle_cube >gfx_obstacle_cube <ctrl_obstacle >ctrl_obstacle 17 0
obstacle_cone_init:
    28 12     is_obstacle cyan        <gfx_obstacle_cone >gfx_obstacle_cone <ctrl_obstacle >ctrl_obstacle 17 0
dummy_init:
    0 0       is_inactive  black     0 0           <ctrl_dummy >ctrl_dummy 9 0
sprite_inits_end:
