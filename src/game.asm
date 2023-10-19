game_won:
    lda #snd_doh_dissolving
    jsr play_sound
    jsr wait_for_silence
    lda has_24k
    beq +n
    lda #snd_hiscore
    ldx #<txt_game_won
    ldy #>txt_game_won
    jsr round_intro
n:

game_over:
    lda #0
    sta is_running_game
    sta mode_break

    jsr wait_for_silence
    lda has_24k
    beq +n
    jsr enter_hiscore
n:  jsr clear_screen

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

switch_to_player_bricks:
    lda #>bricks1
    ldy active_player
    dey
    beq +n
    lda bricks2
n:  sta bricks
    rts

g:  jmp game_won

game:
    lda has_24k
    beq +n
    lda #snd_theme
    ldx #<txt_round_intro
    ldy #>txt_round_intro
    jsr round_intro
n:  jsr clear_data
    jsr preshift_common_sprites
    jsr init_screen
    jsr init_foreground
    jsr init_score

    lda #3
    sta lives1
    ldy has_two_players
    beq +n
    sta lives2
    inc active_player
    lda #1
    sta level
    sta @(+ level 2)
    jsr switch_to_player_bricks
    jsr get_level
    dec active_player
n:

next_level:
    lda #0
    sta is_running_game
    sta mode_break

    ldx active_player
    inc level,x
    lda level,x
    sta level
    cmp #@(++ doh_level)
    beq -g

if @*demo?*
    lda level
    cmp #@(++ num_demo_levels)
    bne +n
    jmp end_of_demo
n:
end

    jsr init_silver_score
    jsr switch_to_player_bricks
    jsr get_level

retry:
    jsr clear_screen
    ldx active_player
    lda level,x
    sta level

    ;; Pre-shift obstacle animation.
    ; Clear destination area.
    lda has_3k
    beq +n
    0
    stzmw d <gfx_obstacles >gfx_obstacles
    stzw c $00 $09
    call <clrram >clrram
    0
n:

    ; Get graphics for current level.
    ldy level
    lda @(-- level_obstacle),y
    cmp #none
    beq no_obstacle_preshifts

    tay
    lda gfx_obstacles_gl,y
    sta @(+ obstacle_init sprite_init_gfx_l)
    sta sl
    lda gfx_obstacles_gh,y
    sta @(+ obstacle_init sprite_init_gfx_h)
    sta sh
    lda gfx_obstacles_gl_end,y
    sta cl
    lda gfx_obstacles_gh_end,y
    sta ch

    lda has_3k
    beq no_obstacle_preshifts

    ; Pre-shift animation.
    lda gfx_obstacles
    sta d
    lda @(++ gfx_obstacles)
    sta dh

l:  ldx #0
    ldy #17
    jsr preshift_huge_sprite

    lda #16
    jsr add_sb
    lda s
    cmp c
    bne -l
    lda sh
    cmp ch
    bne -l

    ; Save end of animation.
    lda dl
    sta gfx_obstacles_end
    lda dh
    sta @(++ gfx_obstacles_end)

no_obstacle_preshifts:

redraw_game:
    ;; Draw DOH instead of level.
    lda level
    cmp #doh_level
    bne +n
    jsr init_doh_charset
    jmp +m

n:  jsr switch_to_player_bricks
    jsr draw_level
m:  jsr draw_walls
    jsr init_scores_and_labels
    jsr switch_player_score

    ;; DOH level init
    lda level
    cmp #doh_level
    bne +n
    lda #16
    ldy active_player
    sta @(-- bricks_left),y
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

    ; Handle completed level.
    ldy active_player
    lda @(-- bricks_left),y
    bne +n
    jmp level_complete

    ; Handle lost life.
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
n:  ldy has_digis
    beq +l
    cmp #keycode_m
    bne +n
    lda is_playing_digis
    eor #1
    sta is_playing_digis
    jsr wait_keyunpress
l:  jmp +l
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
end
if @*demo?*
    cmp #num_demo_levels
    beq end_of_demo2
end
if @*debug?*
    lda #0
    ldy active_player
    sta @(-- bricks_left),y
    jmp next_level

n:  cmp #keycode_c
    bne +n
    inc has_paused
    jsr wait_keyunpress
    jsr show_charset
    jsr clear_screen
    jsr draw_walls
    jsr draw_lives
    jsr draw_level
    jsr draw_lives
    jsr print_scores_and_labels
    dec has_paused

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

    ;; Redraw graphics that have changed.
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
    ; Decrement number of lives.
    ldx active_player
    dec @(-- lives1),x

    ; Handle game over.
    lda lives1
    ora lives2
    bne +n
    jmp game_over

    ; Print "PLAYER X".
n:  lda @(-- lives1),x
    bne +n
    lda #<txt_player1
    ldy #>txt_player1
    cpx #1
    beq +l
    lda #<txt_player2
    ldy #>txt_player2
l:  sta sl
    sty sh
    lda #white
    sta curcol
    lda #16
    sta curchar
    lda #5
    sta scrx2
    lda playfield_yc
    clc
    adc #20
    sta scry
    inc curchar
    jsr clear_curchar
    jsr print_string
    inc curchar
    lda #16
    sta scrx2
    lda #<txt_game_over2
    ldy #>txt_game_over2
    jsr print_string_ay
    inc curchar
    lda has_24k
    beq +n
    jsr enter_hiscore

n:  jsr wait_for_silence

    ;; Switch to player with lives left.
    dec active_player
    lda active_player
    eor #1
    sta active_player
    inc active_player
    ldx active_player
    lda @(-- lives1),x
    beq -n
    jmp retry

level_complete:
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
    lda #0
    sta scrx2
    lda #21
    sta scry
    lda #<txt_preview
    ldy #>txt_preview
    jsr print_string_ay
    lda #0
    sta scrx2
    lda #23
    sta scry
    lda #<txt_preview2
    ldy #>txt_preview2
    jsr print_string_ay
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

txt_game_over:  @(string4x8 "GAME  OVER") 255
txt_game_over2: @(string4x8 "GAME OVER") 255

if @*demo?*
txt_preview:  @(string4x8 "   SOON TO BE AVAILABLE ON") 255
txt_preview2: @(string4x8 "      TAPESONDEMAND.COM") 255
end
