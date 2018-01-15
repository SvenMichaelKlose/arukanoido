ctrl_laser:
    lda #8
    jsr sprite_up

    ldy #0
    sty has_hit_golden_brick
    sty laser_has_hit
    iny
    sty is_testing_laser_hit

    lda sprites_y,x
    cmp arena_y
    bcc +n              ; Laser left the playfield.

    ; Check on collision on the left hand side.
    lda sprites_x,x
    ldy sprites_y,x
    jsr get_soft_collision
    beq +o              ; Nothing, try on the right…
    jsr hit_brick
    bcs +o              ; No brick hit.
    inc laser_has_hit
    jsr make_bonus

    ; Check on collision on the right hand side.
o:  lda sprites_x,x
    clc
    adc #7
    ldy sprites_y,x
    jsr get_soft_collision
    beq +m
    jsr hit_brick
    bcs +m
    inc laser_has_hit
    jsr make_bonus

    ; Hit left or right?
m:  lda laser_has_hit
    ora has_hit_golden_brick
    bne +n

    ; Hit obstacle instead?
    jsr find_hit
    bcs +r
    lda sprites_i,y
    and #is_obstacle
    beq +r
    jsr remove_obstacle

n:  jsr remove_sprite
r:  dec is_testing_laser_hit
    rts
