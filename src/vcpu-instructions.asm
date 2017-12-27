; Call system function without argument mapping.
apply:
    lda (bcp),y
    tax
    dex
    jsr inc_bcp
    lda syscall_vectors_l,x
    sta apply_tmp
    lda syscall_vectors_h,x
    sta @(++ apply_tmp)
    jmp (apply_tmp)

; Set zero page word.
setzw:
    ldx a0
    lda a1
    sta 0,x
    lda a2
    sta 1,x
    rts

; Set zero page word s and d.
setsd:
    lda a0
    sta s
    lda a1
    sta @(++ s)
    lda a2
    sta d
    lda a3
    sta @(++ d)
    rts

; Clear memory area. Byte length.
clrmb:
    lda a0
    sec
    sbc #1
    sta d
    lda a1
    sbc #0
    sta @(++ d)
    ldy a2
    lda #0
l:  sta (d),y
    dey
    bne -l
    rts

; Clear memory area. Word length.
clrmw:
    lda a0
    sta d
    lda a1
    sta @(++ d)
    lda a2
    sta c
    ldy a3
    iny
    sty @(++ c)
    lda #0
    tay
l:  sta (d),y
    inc d
    bne +n
    inc @(++ d)
n:  dec c
    bne -l
    dec @(++ c)
    bne -l
    rts

; Clear memory area. Byte length.
setmb:
    lda a0
    sec
    sbc #1
    sta d
    lda a1
    sbc #0
    sta @(++ d)
    ldy a2
    lda a3
l:  sta (d),y
    dey
    bne -l
    rts

; Set memory area. Word length.
setmw:
    lda a0
    sta d
    lda a1
    sta @(++ d)
    lda a2
    sta c
    ldy a3
    iny
    sty @(++ c)
    lda a4
    ldy #0
l:  sta (d),y
    inc d
    bne +n
    inc @(++ d)
n:  dec c
    bne -l
    dec @(++ c)
    bne -l
    rts
