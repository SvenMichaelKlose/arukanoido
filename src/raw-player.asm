; X: Sound index
raw_start:
    jsr digi_nmi_stop

    lda @(-- sample_addrs_b),x
    sta $9ffe

    ; Set NMI vector.
    lda #<raw_play_sample
    sta $318
    lda #>raw_play_sample
    sta $319

    jmp digi_nmi_start

raw_play_sample:
    sta digisound_a
    sty digisound_y
    lda $9114
    ldy #0
    lda (@(++ raw_play_ptr)),y
    beq +done
    sta $900e
    inc raw_play_ptr
    beq +n
    ldy digisound_y
    lda digisound_a
    rti

    ; Go to next page.
n:  inc @(+ 1 raw_play_ptr)
    lda @(+ 1 raw_play_ptr)
    cmp #$c0
    beq +n
    ldy digisound_y
    lda digisound_a
    rti

    ; Go to next bank.
n:  lda #$a0
    sta @(+ 1 raw_play_ptr)
    inc $9ffe
    ldy digisound_y
    lda digisound_a
    rti

done:
    lda #0
    sta current_song
    jsr digi_nmi_stop
    ldy digisound_y
    lda digisound_a
    rti
