; X: Sound index
raw_start:
    lda @(-- sample_addrs_l),x                                                                                                                                                                        
    sta @(+ 1 raw_play_ptr)
    lda @(-- sample_addrs_h),x
    sta @(+ 2 raw_play_ptr)
    lda @(-- sample_addrs_b),x
    sta $9ffe

    ldx #$60        ; Disable NMI timer and interrupt.
    stx $911e

    ldx #<digisound_timer_pal
    ldy #>digisound_timer_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_ntsc
    ldy #>digisound_timer_ntsc
n:  stx $9114
    sty $9115
    sty exm_timer

    ; Set NMI vector.
    lda #<raw_play_sample
    sta $318
    lda #>raw_play_sample
    sta $319

    lda #$40        ; Set periodic timer.
    sta $911b
    lda #$e0        ; Enable NMI timer and interrupt.
    sta $911e

    rts

raw_play_sample:
    sta digisound_a
    sty digisound_y
    ldy #0
    lda (@(++ raw_play_ptr)),y
    beq +done
    sta $900e
    inc @(+ 1 raw_play_ptr)
    bne +n
    lda @(+ 1 raw_play_ptr)
    cmp #$c0
    bne +n
    lda #$a0
    sta @(+ 1 raw_play_ptr)
    inc $9ffe
r:  ldy digisound_y
    lda digisound_a
    rti

done:
    lda #0
    sta current_song
    lda #$7f
    sta $911e
    bne -r
