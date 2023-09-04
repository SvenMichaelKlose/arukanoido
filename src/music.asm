init_music      = $218d
play_music      = $2027
current_song    = $03d4
requested_song  = $03d6

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

num_tunes             = 17

sound_priorities:
    0 ; no sound
    2 ; 1   theme
    2 ; 2   round
    2 ; 3   bonus life
    2 ; 4   game over
    2 ; 5   DOH round
    2 ; 6   hiscore
    0 ; 7   reflection low
    0 ; 8   reflection high
    0 ; 9   reflection silver
    0 ; 10  caught ball
    2 ; 11  miss
    1 ; 12  hit DOH
    2 ; 13  DOH dissolving
    2 ; 14  growing vaus
    1 ; 15  explosion
    1 ; 16  laser
    2 ; 17  warp

if @*has-digis?*
digi_types:
    0 ; no sound
    0 ; 1   theme
    0 ; 2   round
    1 ; 3   bonus life
    0 ; 4   game over
    2 ; 5   DOH round
    0 ; 6   hiscore
    2 ; 7   reflection low
    2 ; 8   reflection high
    2 ; 9   reflection silver
    2 ; 10  caught ball
    0 ; 11  miss
    1 ; 12  hit DOH
    0 ; 13  DOH dissolving
    1 ; 14  growing vaus
    1 ; 15  explosion
    1 ; 16  laser
    0 ; 17  warp

digi_rates:
    0 ; no sound
    0 ; 1   theme
    0 ; 2   round
    0 ; 3   bonus life
    0 ; 4   game over
    0 ; 5   DOH round
    0 ; 6   hiscore
    0 ; 7   reflection low
    0 ; 8   reflection high
    0 ; 9   reflection silver
    0 ; 10  caught ball
    0 ; 11  miss
    0 ; 12  hit DOH
    1 ; 13  DOH dissolving
    0 ; 14  growing vaus
    0 ; 15  explosion
    0 ; 16  laser
    0 ; 17  warp
end

play_sound:
    sta music_tmp

    txa
    pha
    tya
    pha

    ldx music_tmp
    ldy current_song
    beq +play

    lda sound_priorities,y
    cmp sound_priorities,x
    beq +play
    bcs +done

play:
if @*has-digis?*
    jsr digi_nmi_stop       ; Disable sample player.
    lda #$ff                ; Disable sample decruncher.
    sta exm_needs_data

    lda is_playing_digis
    beq play_native

    jsr audio_boost
end

if @*ultimem?*
    lda has_ultimem
    beq +n

    ; Play raw sample from Ultimem.
    ldx music_tmp
    jsr raw_start
    jmp +r
end

if @*has-digis?*
n:  lda digi_types,x
    bne +m

    ; Play EXM-compressed sample. (type 0)
    lda #1
    sta currently_playing_digis
    lda @(-- sample_addrs_l),x
    ldy @(-- sample_addrs_h),x
    jsr init_decruncher
    ldx music_tmp
    jsr exm_start
    jmp +r

    ; Play RLE-compressed sample. (type 1)
m:  lsr
    bne play_native
    lda #1
    sta currently_playing_digis
    jsr rle_start

r:  lda music_tmp
    sta current_song
    lda #$ff                ; Stop native player.
    sta requested_song
    bne +done               ; (jmp)
end

    ; Play VIC tune.
play_native:
    lda #0
    sta currently_playing_digis
    lda #$7e                ; Turn off audio boost.
    sta $900b
    sta $900c
    lda #$ff                ; Disable EXM player.
    sta exm_needs_data
    lda music_tmp
    sta requested_song

done:
    pla
    tay
    pla
    tax
    rts

wait_for_silence:
if @*shadowvic?*
    rts
end
if @*has-digis?*
    lda is_playing_digis
    bne +n
end
l:  lda requested_song
    cmp #$ff
    bne -l
l:  lda current_song
    bne -l
    rts

if @*has-digis?*
n:  jsr exm_work
    lda current_song
    bne -n
    rts
end
