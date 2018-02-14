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
    inx
    bne -l

    lda #0
    sta $9002

    ; Load title screen.
    ldx #5
l:  lda title_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr c2nwarp_reset
    lda #<tape_leader1
    sta $314
    lda #>tape_leader1
    sta $315
    jmp c2nwarp_start

loader:
    org $2000
