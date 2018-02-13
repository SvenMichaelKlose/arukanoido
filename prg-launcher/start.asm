prg_size = @(- prg_end prg)
blk5_size = @(- blk5_end blk5)

start:
    lda #<prg
    sta s
    lda #>prg
    sta @(++ s)
    lda #$ff
    sta d
    lda #$11
    sta @(++ d)
    ldx #@(low prg_size)
    lda #@(++ (high prg_size))
    sta @(++ c)
    jsr copy_forwards

    lda #<loaded_blk5
    sta s
    lda #>loaded_blk5
    sta @(++ s)
    lda #<blk5
    sta d
    lda #>blk5
    sta @(++ d)
    ldx #@(low blk5_size)
    lda #@(++ (high blk5_size))
    sta @(++ c)
    jsr copy_forwards

    jmp $120d

copy_forwards:
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
    rts
