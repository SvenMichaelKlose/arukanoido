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

; Set zero page byte.
i_stzb:
    ldx a0
    lda a1
    sta 0,x
    rts

; Set zero page word.
i_stzw:
    ldx a0
    lda a1
    sta 0,x
    lda a2
    sta 1,x
    rts

; Set memory byte.
i_stmb:
    lda a2
    ldy #0
    sta (a0),y
    rts

; Set memory word.
i_stmw:
    ldy #0
    lda a2
    sta (a0),y
    iny
    lda a3
    sta (a0),y
    rts

; Set zero page locations which are defined
; as instruction arguments, sp there is nothing
; left to do.
i_lday:
i_ldsd:
    rts

; Call regular subroutine.
i_call:
    lda sra
    ldx srx
    ldy sry
    jsr +n
    sta sra
    stx srx
    sty sry
    rts

n:  jmp (a0)

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
    inx
    inc ch
    ldy dl
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
    inx
    inc ch
    ldy #0
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
    inx
    inc ch
    ldy dl
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
