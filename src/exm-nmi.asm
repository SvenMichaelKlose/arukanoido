exm_play_sample:
    sta digisound_a
    lda exm_timer
    sta $9115
exm_play_ptr:
    lda $ffff
    sta $900e
    inc @(+ 1 exm_play_ptr)
    beq +l
    lda digisound_a
    rti

l:  lda @(+ 2 exm_play_ptr)
    eor #1
    sta @(+ 2 exm_play_ptr)
    lda exm_needs_data
    ora #1
    sta exm_needs_data

    lda digisound_a
    rti
