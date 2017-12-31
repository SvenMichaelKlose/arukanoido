frame_timer_pal = @(- (/ (cpu-cycles :pal) 50) 18)
frame_timer_ntsc = @(- (/ (cpu-cycles :ntsc) 50) 158)

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

l:  lda $9004
    bne -l

    lda #<irq
    sta $314
    lda #>irq
    sta $315

    ; Initialise VIA2 Timer 1.
    lda is_ntsc
    bne +n
    ldx #<frame_timer_pal
    ldy #>frame_timer_pal
    jmp +l
n:  ldx #<frame_timer_ntsc
    ldy #>frame_timer_ntsc
l:  stx $9124
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
    bne +n
    tya
    asl
    tay
    pla
    sta (d),y
    
n:  jsr play_music
    jsr set_vaus_color
    lda is_running_game
    beq +done

    jsr call_sprite_controllers
    lda #1
    sta has_moved_sprites

    lda mode_break
    beq +n
    bpl +done
n:  lda level
    cmp #33
    beq +done
    jsr rotate_bonuses
    jsr add_missing_obstacle
    jsr dyn_brick_fx

done:
    lda #$7f        ; Acknowledge IRQ.
    sta $912d

if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end

    jmp $eb18       ; CBM ROM IRQ return

init_music_data: @(fetch-file "sound-init.bin")
init_music_data_end:
init_music_data_size = @(- init_music_data_end init_music_data)
