; String from original ROM.
"Wed,  4 Jun 1986, 16:34 Programmed By Yasu."

clear_data:
    lda #0
    tax
l:  cpx #@(-- hiscore)
    bcs +n
    sta 0,x
n:  sta $200,x
    dex
    bne -l
    rts

start:
    ldx #$ff
    txs
    jsr clear_data

    ; Init VCPU.
    lda #<exec_script
    sta $316
    lda #>exec_script
    sta $317

    jsr init_hiscore
    jsr start_irq
    lda #0
    sta @(++ requested_song)
    lda #snd_bonus_life ; Tell that the tape has finished loading.
    jsr play_sound
    jsr wait_sound
    jmp restart

game_done:
    lda #snd_doh_dissolving
    jsr play_sound
    jsr wait_sound

game_over:
    lda #0
    sta is_running_game

    lda #snd_game_over
    jsr play_sound
    jsr wait_sound
    lda has_hiscore
    beq restart
    lda #snd_hiscore
    jsr play_sound

restart:
    jsr clear_data

if @(not *shadowvic?*)
    jsr roundintro
end

    lda #snd_coin
    jsr play_sound
    jsr wait_sound
;    lda #snd_theme
;    jsr play_sound
;    jsr wait_sound

    jsr init_game_mode

    ; Prepare paddle auto–detection.
    lda $9008
    sta old_paddle_value

    lda #default_num_lifes
    sta lifes
    jsr init_score

    ; Reset level data stream.
    lda #<level_data
    sta current_level
    lda #>level_data
    sta @(++ current_level)

next_level:
    jsr wait_sound

    lda #0
    sta is_running_game
    inc level
    lda level
    cmp #34
    beq game_done

    jsr clear_screen
    jsr draw_level
    jsr draw_walls
    jsr make_score_screen
    jsr display_score

retry:
    lda #0
    sta is_running_game
    sta is_firing
    sta mode
    sta mode_break
    sta reflections_since_last_vaus_hit
    sta snd_reflection
    sta framecounter
    sta @(++ framecounter)
    sta num_obstacles
    sta num_brick_hits
    lda #1
    sta balls
    sta sfx_reflection
    sta bricks_until_bonus
    lda #default_ball_speed
    sta ball_speed
    lda #16
    sta vaus_width
    lda #255
    sta current_bonus

    jsr clear_sprites
    jsr remove_sprites
    jsr draw_walls      ; Freshen up after mode_break.
    jsr draw_lifes
    jsr roundstart

    jsr make_vaus
    jsr make_ball

    ; Initialise sprite frame.
    lda #0
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char
    jsr draw_sprites

    ; Kick off game code in IRQ handler.
    sei
    ldy #0
    sty framecounter
    sty @(++ framecounter)
    iny
    sty is_running_game
    cli

mainloop:
    lda bricks_left
    bne +n
    jsr draw_sprites
    jmp next_level
n:

    lda is_running_game
    bne +n
    jsr wait_sound
poke_unlimited:
    dec lifes
    beq +o
    jmp retry
o:  jmp game_over

n:  ; Toggle sprite frame.
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char

n:  jsr random              ; Improve randomness and avoid CRTC hsync wobble.
    lda has_moved_sprites
    beq -n
    lda #0
    sta has_moved_sprites
    jsr draw_sprites
    lda has_new_score
    beq mainloop
    lda #0
    sta has_new_score
    jsr display_score
    jmp mainloop

show_charset:
    ldx #0
l:  txa
    sta @(+ screen 34),x
    lda #1
    sta @(+ colors 34),x
    dex
    bne -l
    rts
