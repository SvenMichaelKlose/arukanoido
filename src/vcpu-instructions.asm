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

; Copy byte to zero page.
i_stzmb:
    ldy #0
    ldx a0
    lda (a1),y
    sta 0,x
    rts

; Copy word to zero page.
i_stzmw:
    ldy #0
    ldx a0
    lda (a1),y
    sta 0,x
    iny
    lda (a1),y
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

i_mvmzw:
    ldy #0
    sty a3
    beq +n ; (jmp)

i_mvmw:
    ldy #0
n:  lda (a2),y
    sta (a0),y
    iny
    lda (a2),y
    sta (a0),y
    rts

; Set zero page locations which are defined
; as instruction arguments, sp there is nothing
; left to do.
i_ldyi:
i_ldxy:
i_lday:
i_ldsd:
    rts

i_inczbi:
    ldx a0
    inc 0,x
    rts

i_addzbi:
    ldx a0
    lda a1
    clc
    adc 0,x
    sta 0,x
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

; Clear memory area. Word length.
i_clrmw = clrram

; Move memory area upwards.
i_movmw = moveram

; Fill memory area. Word length.
i_setmw:
    lda a4
    jmp setram
