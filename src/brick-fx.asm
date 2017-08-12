start_brick_fx:
    ldx #0
l:  lda screen,x
    jsr +f
    sta screen,x
    lda @(+ 256 screen),x
    jsr +f
    sta @(+ 256 screen),x
    dex
    bne -l
    rts

f:  cmp #bg_brick_special
    bne +n
    lda #bg_brick_fx
n:  rts

do_brick_fx:
    ldx #0
l:  lda screen,x
    jsr brick_fx
    sta screen,x
    lda @(+ 256 screen),x
    jsr brick_fx
    sta @(+ 256 screen),x
    dex
    bne -l
    rts

brick_fx:
    cmp #@bg_brick_fx
    bcc +n
    cmp #bg_brick_fx_end
    bcs +n
    clc 
    adc #1
    rts
n:  bne +r
    lda #bg_brick_special
r:  rts
