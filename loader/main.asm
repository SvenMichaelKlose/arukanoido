main:
    ldx #0
l:  lda loader,x
    sta $2000,x
    lda @(+ loader 256),x
    sta $2100,x
    lda @(+ loader 512),x
    sta $2200,x
    lda @(+ loader 768),x
    sta $2300,x
    lda @(+ loader 1024),x
    sta $2400,x
    lda @(+ loader 1280),x
    sta $2500,x
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

    jmp c2nwarp_start

loader:
    org $2000
