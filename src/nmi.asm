; Y/X: Timer.
nmi_start:
    stx $9114
    sty $9115
    lda #%01000000  ; Set periodic timer.
    sta $911b
    lda #%11000000  ; Enable NMI timer.
    sta $911e
    cli
    rts

nmi_stop:
    lda #%01000000  ; Disable NMI timer.
    sta $911e
    rts
