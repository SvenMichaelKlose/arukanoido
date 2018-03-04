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

sample_addrs_b:
    fill num_tunes

exm_break_out:          @(fetch-file "obj/break-out.2.exm")
exm_explosion:         @(fetch-file "obj/explosion.2.rle")
exm_extension:         @(fetch-file "obj/extension.2.rle")
exm_extra_life:         @(fetch-file "obj/extra-life.2.rle")
exm_laser:         @(fetch-file "obj/laser.4.rle")
exm_lost_ball:         @(fetch-file "obj/lost-ball.2.exm")
;exm_reflection_doh:         @(fetch-file "obj/reflection-doh.2.exm")
exm_reflection_high:         @(fetch-file "obj/reflection-high.1.rle")
exm_reflection_low:         @(fetch-file "obj/reflection-low.1.rle")
