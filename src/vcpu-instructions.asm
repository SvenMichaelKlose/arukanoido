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
    ldy cl
    lda #0
l:  sta (d),y
    dey
    bne -l
    rts

; Clear memory area. Word length.
i_clrmw:
    ldx cl
    beq +n
    inc ch
n:  ldy dl
    lda #0
    sta dl
l:  sta (d),y
    iny
    bne +n
    inc dh
n:  dex
    bne -l
    dec ch
    bne -l
    rts

; Move memory area upwards.
i_movmw:
    ldx cl
    beq +n
    inc ch
n:  ldy #0
l:  lda (s),y
    sta (d),y
    iny
    bne +n
    inc sh
    inc dh
n:  dex
    bne -l
    dec ch
    bne -l
    rts

; Fill memory area. Byte length.
i_setmb:
    ldy cl
    lda a3
l:  sta (d),y
    dey
    bne -l
    rts

; Fill memory area. Word length.
i_setmw:
    ldx cl
    beq +n
    inc ch
n:  ldy dl
    lda a4
    sta dl
l:  sta (d),y
    iny
    bne +n
    inc dh
n:  dex
    bne -l
    dec ch
    bne -l
    rts
