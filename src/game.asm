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

    jsr clear_screen

    0
    stzb curchar 1
    call <make_score_screen_title >make_score_screen_title
    call <display_score >display_score

    stzb curcol white
    stmb <scrx2 >scrx2 12
    0
    lda playfield_yc
    clc
    adc #20
    sta scry
    0
    lday <txt_game_over >txt_game_over
    call <print_string_ay >print_string_ay
    0

    lda #snd_game_over
    jsr play_sound
    jsr wait_sound
    ldx #100
    jsr wait

    rts

game:
    jsr clear_data
    jsr init_screen
    jsr init_foreground

    ; Prepare paddle auto–detection.
    lda $9008
    sta old_paddle_value

    lda #default_num_lifes
    sta lifes
    jsr init_score

next_level:
    lda #0
    sta is_running_game
    sta mode_break

    inc level
    lda level
    cmp #34
    beq game_done

if @*demo?*
    cmp #9
    bne +n
    lda #0
    sta mode_break
    jsr clear_screen
    jsr init_doh_charset
    lda #1
    sta curchar
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
    jmp wait_fire
n:
end

    jsr increase_silver_score

    jsr clear_screen
    lda level
    cmp #33
    bne +n
    jsr init_doh_charset
    jsr draw_doh
    lda #16
    sta bricks_left
    jmp +m
n:  jsr draw_level
m:  jsr draw_walls
    jsr make_score_screen
    jsr display_score

;lda level
;cmp #33
;bne next_level

retry:
    lda #0
    sta is_running_game
    sta is_firing
    sta mode
    sta sprites_d2,x
    sta framecounter
    sta @(++ framecounter)
    sta num_obstacles
    sta num_hits
    sta has_bonus_on_screen
    sta laser_delay_type
    sta removed_bricks
    lda #1
    sta balls
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

    ; Kick off game code in IRQ handler.
    ldy #0
    sty framecounter
    sty @(++ framecounter)
    iny
    sty is_running_game

mainloop:
if @*shadowvic?*
    $22 $02
    jsr irq
end
    lda bricks_left
    beq level_end
    lda is_running_game
    beq loose_life

    ; Toggle sprite frame.
    lda spriteframe
    eor #framemask
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char

n2: jsr get_keypress
    bcc +l
    cmp #keycode_p
    bne +n
    lda #1
    eor has_paused
    sta has_paused
    jsr reset_volume
q:  jsr wait_keyunpress
    jmp +l

n:  ldx #8
m:  cmp bonus_keys,x
    bne +n
    stx next_bonus
    beq -q
n:  dex
    bpl -m

n:  cmp #keycode_n
    bne +l
    lda #0
    sta bricks_left
    jmp next_level

l:
if @*has-digis?*
    jsr exm_work
end
    lda has_moved_sprites
    beq -n2
    lda #0
    sta has_moved_sprites
    jsr draw_sprites

    jmp mainloop

loose_life:
    jsr wait_sound
    jsr remove_sprites
    jsr clear_sprites
    dec lifes
    beq +l
    jmp retry
l:  jmp game_over

level_end:
    ldx #1
    jsr wait
    jsr draw_sprites
    jsr remove_sprites
if @*has-digis?*
    jsr exm_work
end
    ldx #3
    jsr wait
if @*has-digis?*
    jsr exm_work
    jsr exm_work
end
    jsr clear_sprites
    jsr wait_sound
    jmp next_level

bonus_keys:
    keycode_0
    keycode_1
    keycode_2
    keycode_3
    keycode_4
    keycode_5
    keycode_6
    keycode_7

txt_game_over: @(string4x8 "GAME OVER") 255
