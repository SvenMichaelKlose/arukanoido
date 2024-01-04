ctrl_laser:
    lda #8
    jsr sprite_up

    ;; Discard if outside playfield.
    lda sprites_y,x
    cmp arena_y
    bcc +n

    ;; Cpmfigure 'hit_brick'.
    ldy #0
    sty has_hit_golden_brick
    sty laser_has_hit
    iny
    sty is_testing_laser_hit

    ;; Check if bricks were hit.
    ; Check left hand side.
    lda sprites_x,x
    ldy sprites_y,x
    jsr test_laser_hit
    ; Check right hand side.
    lda sprites_x,x
    clc
    adc #7
    ldy sprites_y,x
    jsr test_laser_hit

    ; Remove laser if a brick was hit.
    lda laser_has_hit
    ora has_hit_golden_brick
    bne +n

    ; Hit obstacle instead?
    lda #is_obstacle
    jsr find_hit
    bcs +r
    jsr remove_obstacle

n:  jsr remove_sprite
r:  dec is_testing_laser_hit
    rts

test_laser_hit:
    jsr get_soft_collision
    beq +o              ; Nothing hit…
    jsr hit_brick
    bcs +o              ; No brick hit…
    inc laser_has_hit
o:  rts

