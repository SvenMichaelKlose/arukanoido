sample_addrs_l:
    <exm_round_intro
    <exm_round_start
    <exm_extra_life
    <exm_game_over
    <exm_doh_intro
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
    >exm_doh_intro
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

sample_len_l:
    <exm_round_intro_size
    <exm_round_start_size
    <exm_extra_life_size
    <exm_game_over_size
    <exm_doh_intro_size
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
    >exm_doh_intro_size
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

exm_break_out_size =    @(length (fetch-file "obj/break-out.raw"))
exm_break_out:          @(fetch-file "obj/break-out.exm")
exm_doh_intro_size =   @(length (fetch-file "obj/doh-intro.raw"))
exm_doh_intro:         @(fetch-file "obj/doh-intro.exm")
exm_explosion_size =   @(length (fetch-file "obj/explosion.raw"))
exm_explosion:         @(fetch-file "obj/explosion.exm")
exm_extension_size =   @(length (fetch-file "obj/extension.raw"))
exm_extension:         @(fetch-file "obj/extension.exm")
exm_extra_life_size =   @(length (fetch-file "obj/extra-life.raw"))
exm_extra_life:         @(fetch-file "obj/extra-life.exm")
exm_game_over_size =   @(length (fetch-file "obj/game-over.raw"))
exm_game_over:         @(fetch-file "obj/game-over.exm")
exm_laser_size =   @(length (fetch-file "obj/laser.raw"))
exm_laser:         @(fetch-file "obj/laser.exm")
exm_lost_ball_size =   @(length (fetch-file "obj/lost-ball.raw"))
exm_lost_ball:         @(fetch-file "obj/lost-ball.exm")
;exm_reflection_doh_size =   @(length (fetch-file "obj/reflection-doh.raw"))
;exm_reflection_doh:         @(fetch-file "obj/reflection-doh.exm")
exm_reflection_high_size =   @(length (fetch-file "obj/reflection-high.raw"))
exm_reflection_high:         @(fetch-file "obj/reflection-high.exm")
exm_reflection_low_size =   @(half (length (fetch-file "obj/reflection-low.raw")))
exm_reflection_low:         @(fetch-file "obj/reflection-low.exm")
exm_reflection_med_size =   @(half (length (fetch-file "obj/reflection-med.raw")))
exm_reflection_med:         @(fetch-file "obj/reflection-med.exm")
exm_round_intro_size =   @(length (fetch-file "obj/round-intro.raw"))
exm_round_intro:         @(fetch-file "obj/round-intro.exm")
exm_round_start_size =   @(length (fetch-file "obj/round-start.raw"))
exm_round_start:         @(fetch-file "obj/round-start.exm")
