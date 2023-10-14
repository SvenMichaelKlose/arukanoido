prg_size = @(- prg_end prg)
blk5_size = @(- blk5_end blk5)

start:
    ; Copy PRG to where it should be.
    lda #<prg
    sta s
    lda #>prg
    sta @(++ s)
    lda #$ff
    sta d
    lda #$11
    sta @(++ d)
    ldx #@(++ (low prg_size))
    lda #@(++ (high prg_size))
    sta @(++ c)
    jsr copy_forwards

    ; Copy data to BLK5.
    lda #<loaded_blk5
    sta s
    lda #>loaded_blk5
    sta @(++ s)
    lda #<blk5
    sta d
    lda #>blk5
    sta @(++ d)
    ldx #@(++ (low blk5_size))
    lda #@(++ (high blk5_size))
    sta @(++ c)
    jsr copy_forwards

    ; Start the PRG.
    jmp $120d

copy_forwards:
    ldy #0
    beq +n ; (jmp)
l:  lda (s),y
    sta (d),y
    iny
    bne +n
n:  dex
    bne -l
    dec @(++ c)
    bne -l
    rts
    inc @(++ s)
    inc @(++ d)
    bne -n ; (jmp)
