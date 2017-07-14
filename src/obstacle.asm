control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_ball_init sprite_inits)
    jsr add_sprite
    tax
    lda #32        ; Direction
    sta sprites_d,x
    inc num_obstacles
done:
    rts

ctrl_obstacle:
    lda sprites_y,x
    cmp #24
    bcs +float

    ; Move obstacle in.
    inc sprites_y,x
    rts

float:
    jsr ball_step
    jmp ball_step

done:
    rts

n:
    rts
