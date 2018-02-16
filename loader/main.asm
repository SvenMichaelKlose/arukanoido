loader_size = @(- target loader)

main:
    sei
    lda #$7f
    sta $911e
    sta $912e

    ; Relocate to $2000.
    lda #<loaded_loader
    sta s
    lda #>loaded_loader
    sta @(++ s)
    lda #<loader
    sta d
    lda #>loader
    sta @(++ d)
    ldx #@(low loader_size)
    lda #@(++ (high loader_size))
    sta @(++ c)
    ldy #0
l:  lda (s),y
    sta (d),y
    iny
    bne +n
    inc @(++ s)
    inc @(++ d)
n:  dex
    bne -l
    dec @(++ c)
    bne -l

    jmp load_title

loaded_loader:
    org $2000
loader:
