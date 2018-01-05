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

m:  lda #$60
    sta $911e
    lda is_playing_digis
    beq +l

    lda #$ff
    sta exm_needs_data

    lda @(-- sample_addrs_l),x
    beq +l
    lda @(-- sample_addrs_l),x
    ldy @(-- sample_addrs_h),x
    jsr init_decruncher
    ldx music_tmp
    lda @(-- sample_len_l),x
    ldy @(-- sample_len_h),x
    jsr exm_start
    jmp +n

l:  lda #$ff
    sta exm_needs_data
    lda music_tmp
    sta requested_song
n:  pla
    tay
    pla
    tax
    rts

wait_sound:
    jsr exm_work
    lda requested_song
    cmp #$ff
    bne wait_sound
l:  jsr exm_work
    lda current_song
    bne -l
l:  jsr exm_work
    lda exm_needs_data
    bpl -l

    rts
