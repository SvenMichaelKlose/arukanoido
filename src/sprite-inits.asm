sprite_init_x           = 0
sprite_init_y           = 1
sprite_init_flags       = 2
sprite_init_color       = 3
sprite_init_gfx_l       = 4
sprite_init_ctrl_l      = 5
sprite_init_ctrl_h      = 6
sprite_init_dimensions  = 7
sprite_init_data        = 8

is_inactive  = 128
was_cleared  = 64
fg_collision = 32
is_ball      = 8
is_obstacle  = 4
is_bonus     = 2
is_vaus      = 1

vaus_y      = @(* 29 8)
multiwhite  = @(+ multicolor white)

sprite_inits:
vaus_init:
    64 vaus_y is_vaus     multiwhite <vaus          <ctrl_vaus >ctrl_vaus 10 0
ball_init:
    70 0      is_ball     white      <ball          <ctrl_ball >ctrl_ball 9 0
laser_init:
    0 vaus_y  0           white      <laser         <ctrl_laser >ctrl_laser 9 0
bonus_init:
    0 0       is_bonus    black      <bonus_l       <ctrl_bonus >ctrl_bonus 9 0
obstacle_ball_init:
    28 12     is_obstacle white      <obstacle_ball <ctrl_obstacle >ctrl_obstacle 17 0
dummy_init:
    0 0       is_inactive  black      0             <ctrl_dummy >ctrl_dummy 9 0
sprite_inits_end:
