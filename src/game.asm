game_won:
    lda #snd_doh_dissolving
    jsr play_sound
    jsr wait_for_silence
    lda #snd_hiscore
    ldx #<txt_game_won
    ldy #>txt_game_won
    jsr round_intro

game_over:
    lda #0
    sta is_running_game
    sta mode_break

    jsr clear_screen

    lda #1
    sta curchar
    jsr print_scores_and_labels

    lda #white
    sta curcol
    lda #10
    sta scrx2

    lda playfield_yc
    clc
    adc #20
    sta scry

    lda #<txt_game_over
    ldy #>txt_game_over
    jsr print_string_ay

    lda #snd_game_over
    jsr play_sound
    jsr wait_for_silence
    ldx #100
if @(not *demo?*)
    jmp wait
end
if @*demo?*
    jsr wait
    jmp end_of_demo
end

game:
    lda #snd_theme
    ldx #<txt_round_intro
    ldy #>txt_round_intro
    jsr round_intro
    jsr clear_data
    jsr preshift_common_sprites
    jsr init_screen
    jsr init_foreground
    jsr init_score

    lda #3
    sta lives1
    ldy has_two_players
    beq +n
    sta lives2
n:

next_level:

if @*demo?*
    lda level
    cmp #@(++ num_demo_levels)
    bne +n
    jmp end_of_demo

g:  jmp game_won

n:
end

    lda #0
    sta is_running_game
    sta mode_break

    inc level
    lda level
    cmp #@(++ doh_level)
    beq -g

    ;; Pre-shift obstacle animation.
    ; Clear destination area.
    lda gfx_obstacles
    sta d
    lda @(++ gfx_obstacles)
    sta @(++ d)
    lda #$00
    sta c
    lda #$09
    sta @(++ c)
    jsr clrram

    ; Get graphics for current level.
    ldy level
    lda @(-- level_obstacle),y
    cmp #none
    beq no_obstacle_preshifts

    tay
    lda gfx_obstacles_gl,y
    sta s
    lda gfx_obstacles_gh,y
    sta @(++ s)
    lda gfx_obstacles_gl_end,y
    sta c
    lda gfx_obstacles_gh_end,y
    sta @(++ c)

    ; Pre-shift animation.
    lda gfx_obstacles
    sta d
    lda @(++ gfx_obstacles)
    sta @(++ d)

l:  ldx #0
    ldy #17
    jsr preshift_huge_sprite

    lda #16
    jsr add_sb
    lda s
    cmp c
    bne -l
    lda @(++ s)
    cmp @(++ c)
    bne -l

    ; Save end of animation.
    lda d
    sta gfx_obstacles_end
    lda @(++ d)
    sta @(++ gfx_obstacles_end)
no_obstacle_preshifts:

    jsr increase_silver_score
    jsr clear_screen

    ;; Draw DOH instead of level.
    lda level
    cmp #doh_level
    bne +n

    jsr init_doh_charset
    bne +m                  ; (jmp)

n:  jsr get_level
    jsr draw_level
m:  jsr draw_walls

retry:
    jsr init_scores_and_labels
    jsr switch_player_score

    ;; DOH level init
    lda level
    cmp #doh_level
    bne +n
    lda #16
    sta bricks_left
    jsr draw_doh
    lda #240
    sta doh_wait

n:  lda #0
    sta is_running_game
    sta is_firing
    sta mode
    sta mode_break
    sta framecounter
    sta @(++ framecounter)
    sta num_obstacles
    sta num_doh_obstacles
    sta num_hits
    sta laser_delay_type
    sta removed_bricks_for_bonus
    sta bonus_is_dropping
    sta has_missed_bonus
    sta needs_redrawing_score1
    sta needs_redrawing_hiscore
    sta needs_redrawing_score2
    sta needs_redrawing_lives
    lda #1
    sta balls
    sta hits_before_bonus
    lda #default_ball_speed
    sta ball_speed
    lda #16
    sta vaus_width

    jsr clear_screen_of_sprites
    jsr remove_sprites
    jsr draw_walls      ; Freshen up after mode_break.
    jsr draw_lives
    jsr roundstart

    jsr make_vaus
    jsr make_ball

    ; Initialise sprite frame.
    lda #0
    sta spriteframe
    ora #first_sprite_char
    sta next_sprite_char

    ; Prepare paddle auto–detection.
    lda $9008
    sta old_paddle_value

    ; Initialise frame counter.
    ldy #0
    sty framecounter
    sty @(++ framecounter)

    iny
    sty is_running_game

mainloop:
if @*shadowvic?*
    $22 $02     ; Wait for retrace.
    jsr irq
end

    ; Handle level end.
    lda bricks_left
    bne +n
    jmp level_end
n:  lda is_running_game
    bne +n
    jmp lose_life

    ; Toggle sprite frame.
n:  lda spriteframe
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

if @*has-digis?*
n:  cmp #keycode_m
    bne +n
    lda is_playing_digis
    eor #1
    sta is_playing_digis
    jsr wait_keyunpress
    jmp +l
end

if @*demo?*
end_of_demo2:
    jmp end_of_demo
end

if @*debug?*
n:  ldx #8
m:  cmp bonus_keys,x
    bne +n
    stx next_bonus
    beq -q
n:  dex
    bpl -m

n:  cmp #keycode_n
    bne +n
    lda level
if @*demo?*
    cmp #num_demo_levels
    beq end_of_demo2
end
    lda #0
    sta bricks_left
    jmp next_level

n:  cmp #keycode_c
    bne +n
    jmp show_charset

n:  cmp #keycode_l
    bne +n
    lda #10
    ldy active_player
    sta @(-- lives1),y
    lda #snd_bonus_life
    jsr play_sound
    inc needs_redrawing_lives
end
n:

l:
if @*has-digis?*
    jsr exm_work
end

    lda needs_redrawing_lives
    beq +n
    jsr draw_lives
n:  lda needs_redrawing_score1
    beq +n
    jsr print_score1
n:  lda needs_redrawing_hiscore
    beq +n
    jsr print_hiscore
n:  lda needs_redrawing_score2
    beq +n
    jsr print_score2
n:  lda #0
    sta needs_redrawing_lives
    sta needs_redrawing_score1
    sta needs_redrawing_hiscore
    sta needs_redrawing_score2
    lda has_moved_sprites
    bne +n
    jmp -n2
n:  lda #0
    sta has_moved_sprites
    jsr draw_sprites
    jmp mainloop

lose_life:
    jsr wait_for_silence
    jsr remove_sprites
    jsr clear_screen_of_sprites

    ; Decrement lives.
    ldx active_player
    dec @(-- lives1),x
    lda lives1
    ora lives2
    bne +n
    jmp game_over

    ; Switch active player.
n:  dec active_player
    lda active_player
    eor #1
    sta active_player
    ldx active_player
    inc active_player
    lda lives1,x
    beq -n
    jmp retry

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
    jsr clear_screen_of_sprites
    jsr wait_for_silence
    jmp next_level

if @*demo?*
end_of_demo:
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
end

if @*debug?*
bonus_keys:
    keycode_0
    keycode_1
    keycode_2
    keycode_3
    keycode_4
    keycode_5
    keycode_6
    keycode_7
end

txt_game_over: @(string4x8 "GAME  OVER") 255

if @*demo?*
txt_preview:  @(string4x8 "   SOON TO BE AVAILABLE ON") 255
txt_preview2: @(string4x8 "      TAPESONDEMAND.COM") 255
end
