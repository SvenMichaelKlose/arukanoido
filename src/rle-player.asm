; X: Sound index
rle_start:
    lda @(-- sample_addrs_l),x                                                                                                                                                                        
    sta rle_play_ptr
    lda @(-- sample_addrs_h),x
    sta @(++ rle_play_ptr)

    lda #$60        ; Disable NMI timer and interrupt.
    sta $911e

    lda @(-- digi_rates),x
    bne +m
    ldx #<digisound_timer_pal
    ldy #>digisound_timer_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_ntsc
    ldy #>digisound_timer_ntsc
    jmp +n
m:  ldx #<digisound_timer_fast_pal
    ldy #>digisound_timer_fast_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_fast_ntsc
    ldy #>digisound_timer_fast_ntsc
    jmp +n
n:  stx $9114
    sty $9115
    sty exm_timer

    lda #1
    sta rle_cnt
    ldy #0
    sty rle_singles
    sty rle_bit
    lda (rle_play_ptr),y
    and #$0f
    ora #$b0
    sta rle_val

    ; Set NMI vector.
    lda #<rle_play_sample
    sta $318
    lda #>rle_play_sample
    sta $319

    lda #$40        ; Set periodic timer.
    sta $911b
    lda #$e0        ; Enable NMI timer and interrupt.
    sta $911e

    rts

rle_fetch:
    ldy #0
    lda rle_bit
    lsr
    lda (rle_play_ptr),y
    bcc +n
    lsr
    lsr
    lsr
    lsr
    inc rle_play_ptr
    bne +r
    inc @(++ rle_play_ptr)
n:  and #15
r:  inc rle_bit
    rts

rle_play_sample:
    sta digisound_a
    sty digisound_y
    lda exm_timer
    sta $9115
    lda rle_singles
    beq +n
    jsr rle_fetch
    ora #$b0
    sta $900e
    dec rle_singles
    beq +m
    ldy digisound_y
    lda digisound_a
    rti

n:  lda rle_val
    sta $900e
    dec rle_cnt
    beq +m
    ldy digisound_y
    lda digisound_a
    rti

m:  jsr rle_fetch
    cmp #0
    beq +done
    cmp #8
    bcc +n
    and #7
    sta rle_singles
    ldy digisound_y
    lda digisound_a
    rti

n:  sta rle_cnt
    jsr rle_fetch
    ora #$b0
    sta rle_val
r:  ldy digisound_y
    lda digisound_a
    rti

done:
    lda #0
    sta current_song
    lda #$7f
    sta $911e
    bne -r
