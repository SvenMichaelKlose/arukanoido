; X: Sound index
rle_start:
    lda @(-- sample_addrs_l),x                                                                                                                                                                        
    sta @(+ 1 rle_play_ptr)
    lda @(-- sample_addrs_h),x
    sta @(+ 2 rle_play_ptr)

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

    lda #1
    sta rle_cnt
    ldy #0
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

rle_play_sample:
    sta digisound_a
    lda exm_timer
    sta $9115
    lda rle_val
    sta $900e
    dec rle_cnt
    beq +n
    lda digisound_a
    rti

n:  sty digisound_y
    ldy #0
    lda (@(++ rle_play_ptr)),y
    beq +done
    inc @(+ 1 rle_play_ptr)
    bne +n
    inc @(+ 2 rle_play_ptr)
n:  tay
    and #$0f
    ora #$b0
    sta rle_val
    tya
    lsr
    lsr
    lsr
    lsr
    sta rle_cnt
r:  ldy digisound_y
    lda digisound_a
    rti

done:
    lda #0
    sta current_song
    lda #$7f
    sta $911e
    bne -r
