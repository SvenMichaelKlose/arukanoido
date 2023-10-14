preshift_common_sprites:
    lda has_3k
    beq +r

    0
    clrmw $00 $04 $d0 $05
    stmw <d >d $00 $04

    mvmzw <preshifted_vaus >preshifted_vaus d
    stzw s <gfx_vaus >gfx_vaus
    ldxy 1 10
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_vaus_laser >preshifted_vaus_laser d
    stzw s <gfx_vaus_laser >gfx_vaus_laser
    ldyi 10
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_vaus_extended >preshifted_vaus_extended d
    stzw s <gfx_vaus_extended >gfx_vaus_extended
    ldyi 11
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_ball >preshifted_ball d
    stzw s <gfx_ball >gfx_ball
    ldxy 0 9
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_ball_caught >preshifted_ball_caught d
    stzw s <gfx_ball_caught >gfx_ball_caught
    ldxy 0 9
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw @(low (+ laser_init sprite_init_pgl)) @(high (+ laser_init sprite_init_pgl)) d
    stzw s <gfx_laser >gfx_laser
    ldxy 0 9
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <gfx_obstacles >gfx_obstacles d
    0

r:  rts
