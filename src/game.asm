if @*demo?*
txt_preview:  @(string4x8 "   SOON TO BE AVAILABLE ON") 255
txt_preview2: @(string4x8 "      TAPESONDEMAND.COM") 255
end

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
    beq +r
    lda #snd_hiscore
    jmp play_sound

r:  rts

game:
    jsr clear_data

if @(not *shadowvic?*)
    jsr roundintro
end

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
    lda #0
    sta is_running_game

    inc level
    lda level
    cmp #34
    beq game_done

if @*demo?*
    cmp #9
    bne +n
    jsr clear_screen
    jsr draw_doh
    lda #white
    sta curcol
    lda #<txt_preview
    sta s
    lda #>txt_preview
    sta @(++ s)
    lda #0
    sta scrx2
    lda #21
    sta scry
    ldx #255
    jsr print_string
    lda #<txt_preview2
    sta s
    lda #>txt_preview2
    sta @(++ s)
    lda #0
    sta scrx2
    lda #23
    sta scry
    ldx #255
    jsr print_string
    jsr wait_fire
    jmp restart
n:
end

    jsr increase_silver_score

    jsr clear_screen
    lda level
    cmp #33
    bne +n
    jsr draw_doh
    lda #16
    sta bricks_left
    jmp +m
n:  jsr draw_level
m:  jsr draw_walls
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
    sta has_bonus_on_screen
    lda #1
    sta balls
    sta sfx_reflection
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

if @*debug?*
    jsr clear_screen
    jsr show_charset
end

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
    jsr wait_sound
    jmp next_level
n:

    lda is_running_game
    bne +n
    jsr wait_sound
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
