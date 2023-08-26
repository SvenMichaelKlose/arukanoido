frame_timer_pal  = @(- (/ (cpu-cycles :pal)  60) 18)
frame_timer_ntsc = @(- (/ (cpu-cycles :ntsc) 60) 158)

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
    jmp +m
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

irq:
if @*show-cpu?*
    lda #@(+ 8 3)
    sta $900f
end

    lda has_paused
    bne +done

    inc framecounter
    bne +n
    inc @(++ framecounter)

n:  lda is_firing
    beq +n
    dec is_firing

n:  lda mode_break
    beq +n

    lda screen_gate
    sta d
    lda @(++ screen_gate)
    sta @(++ d)
    lda framecounter
    lsr
    and #1
    clc
    adc #bg_break
    pha
    ldy #0
    sta (d),y
    ldy screen_columns
    sta (d),y
    lda is_landscape
    bne +m
    tya
    asl
    tay
    pla
    sta (d),y
    jmp +n
m:  pla
    
n:  lda currently_playing_digis
    bne +n
    jsr play_music
n:  jsr set_vaus_color
    lda is_running_game
    beq +done

    jsr call_sprite_controllers
    lda #1
    sta has_moved_sprites

    lda mode_break
    beq +n
    bpl +done

n:  lda level
    cmp #doh_level
    bne +n2
    jsr flash_doh
    jsr add_missing_doh_obstacle
    jmp +done

n2: jsr rotate_bonuses
    jsr add_missing_obstacle
    jsr dyn_brick_fx

done:
    lda has_new_score
    beq +n

    lda #0
    sta has_new_score
    jsr display_score

n:

if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end

if @*shadowvic?*
    rts
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
