;;; Within the IRQ the game logic is enforced to 60 times per
;;; second, so no matter how badly the sprites kick in, everything
;;; keeps running at a constant speed.  That's not true for
;;; original arcade sounds running via the NMI.

frame_freq = 60
frame_timer_pal  = @(- (/ (cpu-cycles :pal)  frame_freq) 18)
frame_timer_ntsc = @(- (/ (cpu-cycles :ntsc) frame_freq) 158)

init_irq:
    sei
    lda #<irq
    sta $314
    lda #>irq
    sta $315

l:  lda $9004
    bne -l

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
    sei
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
    lda tmp
    pha
    lda tmp2
    pha
    lda tmp3
    pha
    lda tmp4
    pha
    lda scr
    pha
    lda @(++ scr)
    pha
    lda col
    pha
    lda @(++ col)
    pha
    lda scrx
    pha
    lda scry
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

    ; Open break mode gate.
    lda gate_opening
    beq +m
    lda framecounter
    and #%1
    bne +n
    jsr open_break_mode_gate
    dec gate_opening
    jmp +n

    ; Animate break mode gate.
m:  lda screen_gate
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
n:

    ;; Play classic VIC sound.
if @*has-digis?*
    lda currently_playing_digis
    bne +n      ; Digis are decrunched in game loop.
end
    jsr play_music
n:

    lda active_player
    beq +l
    jsr blink_score_label

l:  lda is_running_game
    beq +done

    ;; Run the sprite controllers.
    jsr call_sprite_controllers
    lda #1
    sta has_moved_sprites

    ;; DOH round special treatment.
    lda level
    cmp #doh_level
    bne +n
    jsr flash_doh       ; Flash DOH when hit.
    jsr add_missing_doh_obstacle
    jmp +done

    ;; Regular round treatment.
n:  jsr rotate_bonuses
    lda gate_opening
    bne +n2
    jsr add_missing_obstacle
n2:  jsr dyn_brick_fx

    ;; Animate obstacle gate.
    ldx do_animate_obstacle_gate
    beq +n  ; X=0
    lda gate_opening
    bne +n
    lda framecounter
    and #%11
    bne +n
    dex
    bne +n3 ; X=2
    jsr open_obstacle_gate
    jmp +n
n3: jsr close_obstacle_gate
n:

done:
if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end

    pla
    sta scry
    pla
    sta scrx
    pla
    sta @(++ col)
    pla
    sta col
    pla
    sta @(++ scr)
    pla
    sta scr
    pla
    sta tmp4
    pla
    sta tmp3
    pla
    sta tmp2
    pla
    sta tmp
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
    cli
    rti
