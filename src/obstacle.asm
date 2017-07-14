control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_ball_init sprite_inits)
    jsr add_sprite
    tax
    lda #255        ; Obstacle is moving in.
    sta sprites_d,x
    inc num_obstacles
done:
    rts

ctrl_obstacle:
    lda framecounter
    and #%11
    bne +done

    lda sprites_d,x
    bpl +n

    ; Move obstacle in.
    inc sprites_y,x
    lda sprites_y,x
    cmp #24
    bne +done
    lda #0          ; Obstacle done moving in.
    sta sprites_d,x
done:
    rts

n:
    rts
