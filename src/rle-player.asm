; X: Sound index
rle_start:
    jsr nmi_stop

    lda #1
    sta rle_cnt
    lda #$b8
    sta rle_val
    lda #0
    sta rle_singles
    sta rle_bit

    ; Set NMI vector.
    lda #<rle_play_multiple
    sta $318
    lda #>rle_play_multiple
    sta $319

    jmp digi_nmi_start

rle_fetch_nibble:
    lda rle_bit
    inc rle_bit
    lsr             ; Left or right nibble?
    lda (rle_play_ptr),y
    bcc +n          ; Right…
    lsr
    lsr
    lsr
    lsr
    inc rle_play_ptr
    beq +m
    rts
n:  and #15
    rts
m:  inc @(++ rle_play_ptr)
    rts

rle_play_single:
    sta digisound_a
    sty digisound_y
    lda $9114
rle_play_single_imm:
    ldy #0
    jsr rle_fetch_nibble
    ora #$b0            ; (auxiliary colour)
    sta $900e
    dec rle_singles
    beq +n
    ldy digisound_y
    lda digisound_a
    rti

rle_play_multiple:
    sta digisound_a
    lda $9114
    lda rle_val
    sta $900e
    dec rle_cnt
    beq +m
    lda digisound_a
    rti

; Start next run.
m:  sty digisound_y
    ldy #0
n:  jsr rle_fetch_nibble
    cmp #0
    beq +done
    cmp #8              ; High nibble bit set?
    bcc +n              ; No…

    and #7
    sta rle_singles
    lda #<rle_play_single
    sta $318
    lda #>rle_play_single
    sta $319
    ldy digisound_y
    lda digisound_a
    rti

n:  sta rle_cnt
    jsr rle_fetch_nibble
    ora #$b0
    sta rle_val
    lda #<rle_play_multiple
    sta $318
    lda #>rle_play_multiple
    sta $319
r:  ldy digisound_y
    lda digisound_a
    rti

done:
    jsr nmi_stop
    lda #0
    sta current_song
    jsr stop_audio_boost
    bne -r              ; (jmp)
