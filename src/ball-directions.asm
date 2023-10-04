direction_up    = 128
direction_down  = 0
direction_left  = 192
direction_right = 64

deg_steep   = 20
deg_shallow = 41
direction_ls    = @(+ 128 deg_shallow)
direction_l     = @(+ 128 deg_steep)
direction_r     = @(- 128 deg_steep)
direction_rs    = @(- 128 deg_shallow)
direction_drs   = @(- 128 deg_shallow)
direction_dr    = @(- 128 deg_shallow)
direction_dl    = @(- 128 deg_shallow)
direction_dls   = @(- 128 deg_shallow)

initial_ball_direction          = direction_r
initial_ball_direction_skewed   = direction_rs

;;; A mere sine table.
ball_directions_y:  @(ball-directions-y)
