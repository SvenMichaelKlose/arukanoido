; Call system function without argument mapping.
i_apply:
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
i_setzw:
    ldx a0
    lda a1
    sta 0,x
    lda a2
    sta 1,x
    rts

; Set zero page word s and d.
i_setsd:
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
i_clrmb:
    lda a0
    sta d
    lda a1
    sta @(++ d)
    ldy a2
    lda #0
l:  sta (d),y
    dey
    bne -l
    rts

; Clear memory area. Word length.
i_clrmw:
    lda a2
    sta c
    ldy a3
    iny
    sty @(++ c)
    lda a1
    sta @(++ d)
    lda #0
    sta d
    ldy a0
l:  sta (d),y
    iny
    bne +n
    inc @(++ d)
n:  dec c
    ldx c
    cpx #255
    bne -l
    dec @(++ c)
    bne -l
    rts

; Move memory area upwards.
i_movmw:
    lda a0
    sta s
    lda a1
    sta @(++ s)
    lda a2
    sta d
    lda a3
    sta @(++ d)
    lda a4
    sta c
    lda a5
    sta @(++ c)
    ldy #0
l:  lda (s),y
    sta (d),y
    iny
    bne +n
    inc @(++ s)
    inc @(++ d)
n:  dec c
    ldx c
    cpx #255
    bne -l
    dec @(++ c)
    ldx @(++ c)
    cpx #255
    bne -l
    rts

; Clear memory area. Byte length.
; TODO: Remove. Does not work.
i_setmb:
    lda a0
    sta d
    lda a1
    sta @(++ d)
    ldy a2
    lda a3
l:  sta (d),y
    dey
    bne -l
    rts

; Set memory area. Word length.
i_setmw:
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
