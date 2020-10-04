exm_play_sample:
    sta digisound_a
exm_play_ptr:
    lda $ffff
    sta $900e
    inc @(+ 1 exm_play_ptr)
    beq +l
    lda $9114               ; Clear interrupt flag.
    lda digisound_a
    rti

l:  lda @(+ 2 exm_play_ptr)
    eor #1
    sta @(+ 2 exm_play_ptr)
    lda exm_needs_data
    bmi +done
    ora #1
    sta exm_needs_data

r:  lda $9114               ; Clear interrupt flag.
    lda digisound_a
    rti

done:
    lda #0
    sta current_song
    lda #$7f
    sta $911e
    bne -r  ; (jmp)
