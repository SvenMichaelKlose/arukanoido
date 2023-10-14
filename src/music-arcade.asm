sample_addrs_l:
    <exm_round_intro
    <exm_round_start
    <exm_extra_life
    <exm_game_over
    0 ;<exm_doh_intro
    0
    0 ;<exm_reflection_low
    0 ;<exm_reflection_med
    0 ;<exm_reflection_high
    0 ;<exm_reflection_low
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
    0 ;>exm_reflection_low
    0 ;>exm_reflection_med
    0 ;>exm_reflection_high
    0 ;>exm_reflection_low
    >exm_lost_ball
    0
    0
    >exm_extension
    >exm_explosion
    >exm_laser
    >exm_break_out

sample_addrs_b:
    fill num_tunes

exm_break_out:          @(fetch-file "obj-audio/break-out.3.4000.exm")
exm_explosion:          @(fetch-file "obj-audio/explosion.3.4000.rle")
exm_extension:          @(fetch-file "obj-audio/extension.3.4000.rle")
exm_extra_life:         @(fetch-file "obj-audio/extra-life.3.4000.rle")
;exm_laser:              @(fetch-file "obj-audio/laser.3.4000.rle")
;exm_lost_ball:          @(fetch-file "obj-audio/lost-ball.3.4000.exm")
;exm_reflection_doh:     @(fetch-file "obj-audio/reflection-doh.2.4000.exm")
;exm_reflection_high:    @(fetch-file "obj-audio/reflection-high.1.4000.rle")
;xm_reflection_low:      @(fetch-file "obj-audio/reflection-low.1.4000.rle")
