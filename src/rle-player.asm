rle_play_ptr = @(++ exm_play_ptr)

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

    lda #$40        ; Set periodic timer.
    sta $911b
    lda #$e0        ; Enable NMI timer and interrupt.
    sta $911e

    rts

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
    lda exm_timer
    sta $9115
    sty digisound_y
    ldy #0
    jsr rle_fetch
    ora #$b0
    sta $900e
    dec rle_singles
    beq +m
    ldy digisound_y
    lda digisound_a
    rti

rle_play_multiple:
    sta digisound_a
    lda exm_timer
    sta $9115
    sty digisound_y
    ldy #0
    lda rle_val
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
    lda #$7f
    sta $911e
    bne -r
