frame_timer_pal = @(- (/ (cpu-cycles :pal) 50) 18)
frame_timer_ntsc = @(- (/ (cpu-cycles :ntsc) 50) 158)

start_irq:
    lda #0
    sta is_running_game

l:  lda $9004
    bne -l

    lda #<irq
    sta $314
    lda #>irq
    sta $315

    ; Initialise VIA2 Timer 1.
    ldx #<frame_timer_pal
    ldy #>frame_timer_pal
    lda $ede4
    cmp #$0c
    beq +p
    ldx #<frame_timer_ntsc
    ldy #>frame_timer_ntsc
p:  stx $9124
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

    inc framecounter
    bne +n
    inc @(++ framecounter)
n:

    lda mode_break
    beq +n
    lda framecounter
    lsr
    and #1
    clc
    adc #bg_break
    sta @(+ screen (* 15 28) 14)
    sta @(+ screen (* 15 29) 14)
    sta @(+ screen (* 15 30) 14)
n:

n:  jsr play_music
    jsr set_vaus_color
    lda is_running_game
    beq +n

    jsr call_sprite_controllers
    lda #1
    sta has_moved_sprites

    lda mode_break
    bne +n
    jsr rotate_bonuses
    jsr control_obstacles

n:  lda #$7f        ; Acknowledge IRQ.
    sta $912d

if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end

    jmp $eb18       ; CBM ROM IRQ return
