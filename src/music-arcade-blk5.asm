exm_round_intro:
if @*rom?*
    @(fetch-file "obj-audio/round-intro.4.4000.exm")
end
if @(not *rom?*)
    @(fetch-file "obj-audio/round-intro.3.4000.exm")
end
exm_round_start:        @(fetch-file "obj-audio/round-start.3.4000.exm")
;exm_reflection_med:     @(fetch-file "obj-audio/reflection-med.1.4000.rle")
exm_game_over:          @(subseq (fetch-file "obj-audio/game-over.3.4000.exm")
                                 0 #x1e10)
