game_done:
    lda #snd_doh_dissolving
    jsr play_sound
    jsr wait_for_silence

game_over:
    lda #0
    sta is_running_game
    sta mode_break

    jsr clear_screen

    lda #1
    sta curchar
    jsr make_score_screen_title
    jsr display_score

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
    jsr wait

    rts

game:
    jsr clear_data
    jsr preshift_common_sprites
    jsr init_screen
    jsr init_foreground

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

    ; Pre-shift obstacle animation.
    ldy level
    lda @(-- level_obstacle),y
    tay
    lda gfx_obstacles_gl,y
    sta s
    lda gfx_obstacles_gh,y
    sta @(++ s)
    lda gfx_obstacles_gl_end,y
    sta c
    lda gfx_obstacles_gh_end,y
    sta @(++ c)
    lda gfx_obstacles
    sta d
    lda @(++ gfx_obstacles)
    sta @(++ d)
l:  ldx #0
    ldy #17
    jsr preshift_huge_sprite
    lda s
    clc
    adc #16
    sta s
    bcc +n
    inc @(++ s)
n:  lda s
    cmp c
    bne -l
    lda @(++ s)
    cmp @(++ c)
    bne -l

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

retry:
    lda #0
    sta is_running_game
    sta is_firing
    sta mode
    sta mode_break
    sta sprites_d2,x
    sta framecounter
    sta @(++ framecounter)
    sta num_obstacles
    sta num_hits
    sta bonus_on_screen
    sta laser_delay_type
    sta removed_bricks
    lda #1
    sta balls
    lda #default_ball_speed
    sta ball_speed
    lda #16
    sta vaus_width

    jsr clear_screen_of_sprites
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

    ; Prepare paddle auto–detection.
    lda $9008
    sta old_paddle_value

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
    beq lose_life

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

;if @*demo?*
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
;end
n:

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

lose_life:
    jsr wait_for_silence
    jsr remove_sprites
    jsr clear_screen_of_sprites
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
    jsr clear_screen_of_sprites
    jsr wait_for_silence
    jmp next_level

;if @*demo?*
bonus_keys:
    keycode_0
    keycode_1
    keycode_2
    keycode_3
    keycode_4
    keycode_5
    keycode_6
    keycode_7
;end

txt_game_over: @(string4x8 "GAME  OVER") 255

if @*demo?*
txt_preview:  @(string4x8 "   SOON TO BE AVAILABLE ON") 255
txt_preview2: @(string4x8 "      TAPESONDEMAND.COM") 255
end
