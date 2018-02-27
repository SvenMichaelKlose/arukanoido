; X: Sound index
rle_start:
    jsr digi_nmi_stop

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

rle_fetch:
    lda rle_bit
    inc rle_bit
    lsr
    lda (rle_play_ptr),y
    bcc +n
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
    ldy #0
    jsr rle_fetch
    ora #$b0
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

m:  sty digisound_y
    ldy #0
n:  jsr rle_fetch
    cmp #0
    beq +done
    cmp #8
    bcc +n
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
    jsr rle_fetch
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
    lda #0
    sta current_song
    jsr digi_nmi_stop
    bne -r
