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
    bne +o              ; Nothing, try on the right…
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
    bne +m
    jsr hit_brick
    bcc +f              ; We hit a brick…

    ; Move laser up unless it hit a brick.
m:  lda laser_has_hit
    ora has_hit_golden_brick
    bne +n
    jmp +done

f:  jsr make_bonus
n:  jsr remove_sprite   ; Remove laser sprite.
    lda #0
    sta is_testing_laser_hit
    rts

done:
    lda #0
    sta is_testing_laser_hit

    ; Hit obstacle?
    jsr find_hit
    bcs +n
    lda sprites_i,y
    and #is_obstacle
    beq +n
    jsr remove_obstacle
    jmp remove_sprite
n:  rts

remove_lasers:
    txa
    pha
    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    and #is_laser
    beq +n
    jsr remove_sprite
n:  dex
    bpl -l
    pla
    tax
r:  rts
