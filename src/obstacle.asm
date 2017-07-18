control_obstacles:
    lda num_obstacles
    cmp #3
    beq +done
    lda framecounter
    bne +done
    ldy #@(- obstacle_cube_init sprite_inits)
    jsr add_sprite
    tax
    lda #56        ; Direction
    sta sprites_d,x
    inc num_obstacles
done:
    rts

ctrl_obstacle:
    lda framecounter
    lsr
    bcs +r

    lda sprites_y,x
    cmp #24
    bcs +n

    ; Move obstacle in.
    inc sprites_y,x
r:  rts
n:

    lda sprites_x,x
    cmp #15
    bcs +n
    lda #56
    sta sprites_d,x
n:

    lda sprites_x,x
    cmp #@(* (- screen_columns 2) 8)
    bcc +n
    lda #198
    sta sprites_d,x
n:

    ; Animate obstacle.
    lda framecounter
    and #7
    bne +n
    lda sprites_gl,x
    clc
    adc #32
    sta sprites_gl,x
    lda sprites_gh,x
    adc #0
    sta sprites_gh,x
    lda sprites_gl,x
    cmp #<gfx_obstacle_cube_end
    bne +n
    lda #<gfx_obstacle_cube
    sta sprites_gl,x
    lda #>gfx_obstacle_cube
    sta sprites_gh,x
n:

    jsr ball_step
    jsr ball_step

    ; Check on collision with background.
    ; Check on collision with other obstacle or Vaus.
    jsr find_hit
    bcs +done
    lda sprites_i,y
    and #is_vaus
    beq +done

; Y: Sprite index
remove_obstacle:
    txa
    pha
    tya
    tax
    jsr remove_sprite
    dec num_obstacles
    pla
    tax
    rts

done:
    rts
