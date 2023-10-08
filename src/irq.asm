;;; Within the IRQ the game logic is enforced to 60 times per
;;; second, so no matter how badly the sprites kick in, everything
;;; keeps running at a constant speed.  That's not true for
;;; original arcade sounds running via the NMI.

frame_freq = 60
frame_timer_pal  = @(- (/ (cpu-cycles :pal)  frame_freq) 18)
frame_timer_ntsc = @(- (/ (cpu-cycles :ntsc) frame_freq) 158)

start_irq:
    lda #0
    sta is_running_game

    ldx #0
    ldy #init_music_data_size
l:  lda init_music_data,x
    sta $3ce,x
    inx
    dey
    bne -l
    jsr init_music

l:  lda #<irq
    sta $314
    lda #>irq
    sta $315

    ; Initialise VIA2 Timer 1.
    lda is_ntsc
    bne +n
    ldx #<frame_timer_pal
    ldy #>frame_timer_pal
l:  lda $9004
    cmp #135
    bne -l
    beq +m          ; (jmp)
n:  ldx #<frame_timer_ntsc
    ldy #>frame_timer_ntsc
m:  stx $9124
    sty $9125
    lda #%01000000  : free-running
    sta $912b
    lda #%11000000  ; IRQ enable
    sta $912e
    cli
    rts
done:
    jmp +done

irq:
    lda s
    pha
    lda @(++ s)
    pha
    lda d
    pha
    lda @(++ d)
    pha
    lda c
    pha
    lda @(++ c)
    pha

if @*show-cpu?*
    lda #@(+ 8 3)
    sta $900f
end

    ;; Handle pause.
    lda has_paused
    bne -done

    ;; Increment framecounter.
    inc framecounter
    bne +n
    inc @(++ framecounter)

    ;; Handle laser interval.
n:  lda is_firing
    beq +n
    dec is_firing

    ;; Display break mode gate?
n:  lda mode_break
    beq +n

    ;; Animate gate.
    lda screen_gate
    sta d
    sta c
    lda @(++ screen_gate)
    sta @(++ d)
    ora #>colors
    sta @(++ c)

    ; Switch char every two pixels.
    lda framecounter
    lsr
    and #1
    clc
    adc #bg_break
    tax

    ; Redraw gate.
    ldy #0
    sta (d),y
    lda #white
    sta (c),y
    ldy screen_columns
    txa
    sta (d),y
    lda #white
    sta (c),y
    lda is_landscape
    bne +n
    tya         ; Extra gate char in portrait format.
    asl
    tay
    txa
    sta (d),y
    lda #white
    sta (c),y

    ;; Play classic VIC sound.
n:  lda currently_playing_digis
    bne +n      ; Digis are decrunched in game loop.
    jsr play_music
n:

    lda active_player
    beq +l

    ;; Blink score label of active player.
    lda color_1up
    sta d
    lda @(++ color_1up)
    sta @(++ d)
    ldx #red
    lda framecounter
    and #%00100000
    bne +n
    ldx #black
n:  txa
    ldy #0
    sta (d),y
    iny
    sta (d),y

    ;; Run the sprite controllers.
l:  lda is_running_game
    beq +done

    jsr call_sprite_controllers
    ; Done.  Tell main loop to redraw the sprites.
    lda #1
    sta has_moved_sprites

    lda mode_break
    beq +n
    bpl +done

    ;; DOH round special treatment.
n:  lda level
    cmp #doh_level
    bne +n2
    jsr flash_doh       ; Flash DOH when hit.
    jsr add_missing_doh_obstacle
    jmp +done

    ;; Regular round treatment.
n2: jsr rotate_bonuses
    jsr add_missing_obstacle
    jsr dyn_brick_fx

done:
if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end

    pla
    sta @(++ c)
    pla
    sta c
    pla
    sta @(++ d)
    pla
    sta d
    pla
    sta @(++ s)
    pla
    sta s

if @*shadowvic?*
    rts             ; ShadowVIC emulator doesn't require IRQs.
end
    pla
    tay
    pla
    tax
    lda #$7f        ; Acknowledge IRQ.
    sta $912d
    pla
    rti

init_music_data: @(fetch-file "sound-init.bin")
init_music_data_end:
init_music_data_size = @(- init_music_data_end init_music_data)
