control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_cube_init sprite_inits)
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
    jsr ball_step

    ; Check on collision with background.
    ; Check on collision with other obstacle or Vaus.
    jsr find_hit
    bcs +done
    lda sprites_i,y
    and #is_vaus
    beq +done
remove_obstacle:
    dec num_obstacles
    jmp remove_sprite

done:
    rts

n:
    rts
