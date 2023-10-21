exm_round_intro:
if @*rom?*
    @(fetch-file "obj-audio/round-intro.4.4000.exm")
end
if @(not *rom?*)
    @(fetch-file "obj-audio/round-intro.3.4000.exm")
end
exm_round_start:        @(fetch-file "obj-audio/round-start.3.4000.exm")
;exm_reflection_med:     @(fetch-file "obj-audio/reflection-med.1.4000.rle")
exm_game_over:          @(subseq (fetch-file "obj-audio/game-over.4.4000.exm")
                                 0 #x1e10)
;exm_laser:              @(fetch-file "obj-audio/laser.3.4000.rle")
exm_lost_ball:          @(fetch-file "obj-audio/lost-ball.3.4000.exm")
;exm_break_out:          @(fetch-file "obj-audio/break-out.3.4000.exm")
;exm_explosion:          @(fetch-file "obj-audio/explosion.3.4000.rle")
;exm_extension:          @(fetch-file "obj-audio/extension.3.4000.rle")
;exm_extra_life:         @(fetch-file "obj-audio/extra-life.3.4000.rle")
