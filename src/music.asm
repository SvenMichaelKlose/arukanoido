init_music = $218d
play_music = $2027
current_song = $03d4
requested_song = $03d6

snd_test              = 3
snd_theme             = 1
snd_round             = 2
snd_bonus_life        = 3
snd_game_over         = 4
snd_doh_round         = 5
snd_hiscore           = 6
snd_reflection_low    = 7
snd_reflection_high   = 8
snd_reflection_silver = 9
snd_caught_ball       = 10
snd_miss              = 11
snd_coin              = 11
snd_hit_doh           = 12
snd_doh_dissolving    = 13
snd_growing_vaus      = 14
snd_hit_obstacle      = 15
snd_laser             = 16
snd_round_break       = 17

sound_priorities:
    0 ; no sound
    2 ; 1
    2 ; 2
    2 ; 3
    2 ; 4
    2 ; 5
    2 ; 6
    0 ; 7
    0 ; 8
    0 ; 9
    0 ; 10
    2 ; 11
    1 ; 12
    2 ; 13
    2 ; 14
    1 ; 15
    1 ; 16
    1 ; 17

play_sound:
    sta music_tmp
    txa
    pha
    tya
    pha
    ldx music_tmp
    ldy current_song
    lda sound_priorities,y
    cmp sound_priorities,x
    beq +m
    bcs +n
m:  lda music_tmp
    sta requested_song
n:  pla
    tay
    pla
    tax
    rts

wait_sound:
    jsr random              ; Avoid CRTC hsync sine wave wobble.
    lda requested_song
    cmp #$ff
    bne wait_sound
l:  jsr random
    lda current_song
    bne -l
    rts

exm_test:
    lda #<exm_extra_life
    ldy #>exm_extra_life
    jsr init_decruncher
    lda #<exm_extra_life_size
    ldy #>exm_extra_life_size
    jmp exm_start


exm_break_out_size =    @(length (fetch-file "obj/break-out.raw"))
exm_break_out:          @(fetch-file "obj/break-out.exm")
exm_doh_intro_size =   @(length (fetch-file "obj/doh-intro.raw"))
exm_doh_intro:         @(fetch-file "obj/doh-intro.exm")
exm_explosion_size =   @(length (fetch-file "obj/explosion.raw"))
exm_explosion:         @(fetch-file "obj/explosion.exm")
exm_extension_size =   @(length (fetch-file "obj/extension.raw"))
exm_explosion:         @(fetch-file "obj/extension.exm")
exm_extra_life_size =   @(length (fetch-file "obj/extra-life.raw"))
exm_extra_life:         @(fetch-file "obj/extra-life.exm")
exm_game_over_size =   @(length (fetch-file "obj/game-over.raw"))
exm_game_over:         @(fetch-file "obj/game-over.exm")
exm_laser_size =   @(length (fetch-file "obj/laser.raw"))
exm_laser:         @(fetch-file "obj/laser.exm")
exm_lost_ball_size =   @(length (fetch-file "obj/lost-ball.raw"))
exm_lost_ball:         @(fetch-file "obj/lost-ball.exm")
exm_reflection_high_size =   @(length (fetch-file "obj/reflection-high.raw"))
exm_reflection_high:         @(fetch-file "obj/reflection-high.exm")
exm_reflection_low_size =   @(length (fetch-file "obj/reflection-low.raw"))
exm_reflection_low:         @(fetch-file "obj/reflection-low.exm")
exm_reflection_med_size =   @(length (fetch-file "obj/reflection-med.raw"))
exm_reflection_med:         @(fetch-file "obj/reflection-med.exm")
exm_round_intro_size =   @(length (fetch-file "obj/round-intro.raw"))
exm_round_intro:         @(fetch-file "obj/round-intro.exm")
exm_round_start_size =   @(length (fetch-file "obj/round-start.raw"))
exm_round_start:         @(fetch-file "obj/round-start.exm")
