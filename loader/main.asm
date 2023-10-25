loader_size = @(- target loader)

main:
    sei
    lda #$7f
    sta $911e
    sta $912e

if @*ultimem?*
    lda #0
    sta $1100       ; No Ultimem…
    lda $9f55       ; Unhide registers.
    lda $9faa
    lda $9f01
    lda $9ff3
    cmp #$11
    beq +f
    cmp #$12
    bne +n

    ; Activate all Ultimem RAM.
    inc $1100
f:  lda #%00111111
    sta $9ff1
    lda #%11111111
    sta $9ff2
    lda #0
    sta $9ff4
    sta $9ff5
    ldx #1
    stx $9ff6
    sta $9ff7
    inx
    stx $9ff8
    sta $9ff9
    inx
    stx $9ffa
    sta $9ffb
    inx
    stx $9ffc
    sta $9ffd
    inx
    stx $9ffe
    sta $9fff
n:
end

    ; Relocate to $2000.
    lda #<loaded_loader
    sta s
    lda #>loaded_loader
    sta @(++ s)
    lda #<loader
    sta d
    lda #>loader
    sta @(++ d)
    ldx #@(++ (low loader_size))
    lda #@(++ (high loader_size))
    sta @(++ c)
    ldy #0
    beq +n ; (jmp)
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
