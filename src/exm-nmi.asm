exm_play_sample:
    sta digisound_a
    lda $9114               ; Clear interrupt flag.
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
    bmi +done
    ora #1
    sta exm_needs_data

r:  lda digisound_a
    rti

done:
    lda #0
    sta current_song
    jsr stop_audio_boost
    lda #%01000000          ; Disable NMI timer.
    sta $911e
    bne -r  ; (jmp)
