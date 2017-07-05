control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    ldy #@(- obstacle_ball_init sprite_inits)
    jsr add_sprite
    inc num_obstacles

done:
    rts

ctrl_obstacle:
    rts
