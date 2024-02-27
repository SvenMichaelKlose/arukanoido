init_music_imported = $218d
play_music          = $2027
current_song        = $03d4
requested_song      = $03d6

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

mt_exm = 0
mt_rle = 1
mt_vic = 2
if @*has-digis?*
digi_types:
    0 ; no sound
    mt_exm ; 1   theme
    mt_exm ; 2   round
    mt_vic ; 3   bonus life
    mt_exm ; 4   game over
    mt_vic ; 5   DOH round
    mt_vic ; 6   hiscore
    mt_vic ; 7   reflection low
    mt_vic ; 8   reflection high
    mt_vic ; 9   reflection silver
    mt_vic ; 10  caught ball
    mt_exm ; 11  miss
    mt_vic ; 12  hit DOH
    mt_exm ; 13  DOH dissolving
    mt_vic ; 14  growing vaus
    mt_vic ; 15  explosion
    mt_vic ; 16  laser
    mt_exm ; 17  warp

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

init_music_data: @(fetch-file "sound-init.bin")
init_music_data_end:
init_music_data_size = @(- init_music_data_end init_music_data)

init_music:
    0
    movmw $ce $03 <init_music_data >init_music_data <init_music_data_size >init_music_data_size
    0
    jmp init_music_imported

play_sound:
    sta tmp3

    txa
    pha
    tya
    pha

    ldx tmp3
    ldy current_song
    beq +play

    lda sound_priorities,y
    cmp sound_priorities,x
    beq +play
    bcs +done

play:
if @*has-digis?*
    lda is_playing_digis
    beq play_native
    lda #$ff            ; Disable sample decruncher.
    sta exm_needs_data
    jsr audio_boost
end

if @*ultimem?*
    lda has_ultimem
    beq +n

    ; Play raw sample from Ultimem.
    ldx tmp3
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
    ldx tmp3
    jsr exm_start
    jmp +r

    ; Play RLE-compressed sample. (type 1)
m:

if @*rle?*
    lsr
    bne play_native
    lda #1
    sta currently_playing_digis
    jsr rle_start
end
if @(not *rle?*)
    jmp play_native
end

r:  lda tmp3
    sta current_song
    lda #$ff                ; Stop native player.
    sta requested_song
    bne +done               ; (jmp)
end

    ; Play VIC tune. (type 2)
play_native:
if @*has-digis?*
    lda #0
    sta currently_playing_digis
    lda #$7e                ; Turn off audio boost.
    sta $900b
    sta $900c
    lda #$ff                ; Disable EXM player.
    sta exm_needs_data
end
    lda tmp3
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
