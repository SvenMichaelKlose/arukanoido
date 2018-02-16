main:
    sei
    lda #$7f
    sta $911e
    sta $912e

    ldx #0
l:  lda loader,x
    sta $2000,x
    lda @(+ loader #x100),x
    sta $2100,x
    lda @(+ loader #x200),x
    sta $2200,x
    lda @(+ loader #x300),x
    sta $2300,x
    lda @(+ loader #x400),x
    sta $2400,x
    lda @(+ loader #x500),x
    sta $2500,x
    lda @(+ loader #x600),x
    sta $2600,x
    lda @(+ loader #x700),x
    sta $2700,x
    inx
    bne -l

    jmp load_title

loader:
    org $2000
