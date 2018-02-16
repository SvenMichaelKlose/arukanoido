sample_addrs_l:
    <exm_round_intro
    <exm_round_start
    <exm_extra_life
    <exm_game_over
    0 ;<exm_doh_intro
    0
    <exm_reflection_low
    <exm_reflection_med
    <exm_reflection_high
    <exm_reflection_low
    <exm_lost_ball
    0
    0
    <exm_extension
    <exm_explosion
    <exm_laser
    <exm_break_out

sample_addrs_h:
    >exm_round_intro
    >exm_round_start
    >exm_extra_life
    >exm_game_over
    0 ;>exm_doh_intro
    0
    >exm_reflection_low
    >exm_reflection_med
    >exm_reflection_high
    >exm_reflection_low
    >exm_lost_ball
    0
    0
    >exm_extension
    >exm_explosion
    >exm_laser
    >exm_break_out

sample_addrs_b:     fill 24

sample_len_l:
    <exm_round_intro_size
    <exm_round_start_size
    <exm_extra_life_size
    <exm_game_over_size
    0 ;<exm_doh_intro_size
    0
    <exm_reflection_low_size
    <exm_reflection_med_size
    <exm_reflection_high_size
    0
    <exm_lost_ball_size
    0
    0
    <exm_extension_size
    <exm_explosion_size
    <exm_laser_size
    <exm_break_out_size

sample_len_h:
    >exm_round_intro_size
    >exm_round_start_size
    >exm_extra_life_size
    >exm_game_over_size
    0 ;>exm_doh_intro_size
    0
    >exm_reflection_low_size
    >exm_reflection_med_size
    >exm_reflection_high_size
    1
    >exm_lost_ball_size
    0
    0
    >exm_extension_size
    >exm_explosion_size
    >exm_laser_size
    >exm_break_out_size

;exm_break_out_size =    @(length (fetch-file "obj/break-out.2.raw"))
;exm_break_out:          @(fetch-file "obj/break-out.2.exm")
;exm_doh_intro_size =   @(length (fetch-file "obj/doh-intro.2.raw"))
;exm_doh_intro:         @(fetch-file "obj/doh-intro.2.exm")
exm_explosion_size =   @(length (fetch-file "obj/explosion.2.raw"))
exm_explosion:         @(fetch-file "obj/explosion.2.rle")
exm_extension_size =   @(length (fetch-file "obj/extension.2.raw"))
exm_extension:         @(fetch-file "obj/extension.2.rle")
exm_extra_life_size =   @(length (fetch-file "obj/extra-life.4.raw"))
exm_extra_life:         @(fetch-file "obj/extra-life.4.rle")
;exm_game_over_size =   @(length (fetch-file "obj/game-over.2.raw"))
;exm_game_over:         @(fetch-file "obj/game-over.2.exm")
exm_laser_size =   @(length (fetch-file "obj/laser.2.raw"))
exm_laser:         @(fetch-file "obj/laser.2.rle")
exm_lost_ball_size =   @(length (fetch-file "obj/lost-ball.2.raw"))
exm_lost_ball:         @(fetch-file "obj/lost-ball.2.exm")
;exm_reflection_doh_size =   @(length (fetch-file "obj/reflection-doh.2.raw"))
;exm_reflection_doh:         @(fetch-file "obj/reflection-doh.2.exm")
exm_reflection_high_size =   @(length (fetch-file "obj/reflection-high.2.raw"))
exm_reflection_high:         @(fetch-file "obj/reflection-high.2.rle")
exm_reflection_low_size =   @(half (length (fetch-file "obj/reflection-low.4.raw")))
exm_reflection_low:         @(fetch-file "obj/reflection-low.4.rle")
exm_reflection_med_size =   @(half (length (fetch-file "obj/reflection-med.4.raw")))
exm_reflection_med:         @(fetch-file "obj/reflection-med.4.rle")
;exm_round_intro_size =   @(length (fetch-file "obj/round-intro.2.raw"))
;exm_round_intro:         @(fetch-file "obj/round-intro.2.exm")
;exm_round_start_size =   @(length (fetch-file "obj/round-start.2.raw"))
;exm_round_start:         @(fetch-file "obj/round-start.2.exm")
