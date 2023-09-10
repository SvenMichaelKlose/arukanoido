; d = s + d
; Y = length - 1
bcd_add:
    clc
l:  lda (s),y
    adc (d),y
    cmp #10
    bcc +n
    sec
    sbc #10
n:  sta (d),y
    dey
    bpl -l
    rts

; X = length - 1
; C=0: s < d
; C=1: s >= d
; Z=1: s == d
bcd_cmp:
    ldy #0
l:  lda (s),y
    cmp (d),y
    beq +n
    rts
n:  iny
    dex
    bpl -l
    lda #0
    clc
    rts
