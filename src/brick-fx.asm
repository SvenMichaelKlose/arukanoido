brick_fx:
    cmp #@bg_brick_fx
    bcc +n
    cmp #@(-- bg_brick_fx_end)
    beq +l
    cmp #bg_brick_fx_end
    bcs +r
    clc 
    adc #1
    rts
l:  lda #bg_brick_special
r:  rts

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

add_brick_fx:
    lda level
    cmp #33
    beq +r
    stx tmp
    ldy brickfx_end
    iny
    cpy brickfx_pos
    beq undo_brick_fx
l:  lda brickfx_end
    and #@(-- num_brickfx)
    tax
    lda scrx
    sta brickfx_x,x
    tay
    lda #bg_brick_fx
    sta (scr),y
    lda scry
    sta brickfx_y,x
    ldy brickfx_end
    iny
    tya
    and #@(-- num_brickfx)
    sta brickfx_end
    ldx tmp
r:  rts

undo_brick_fx:
    lda scr
    pha
    lda @(++ scr)
    pha
    dey
    lda brickfx_x,y
    sta scrx
    lda brickfx_y,y
    sta scry
    jsr scraddr
    lda #bg_brick_special
    sta (scr),y
    pla
    sta @(++ scr)
    pla
    sta scr
    jmp -l

dyn_brick_fx:
    ldx brickfx_pos
l:  txa
    and #@(-- num_brickfx)
    tax
    cpx brickfx_end
    beq -r
    lda brickfx_x,x
    sta scrx
    lda brickfx_y,x
    sta scry
    jsr scraddr
    lda (scr),y
    jsr brick_fx
    sta (scr),y
    cmp #bg_brick_special
    bne +n
    lda #0
    sta brickfx_x,x
    inc brickfx_pos
n:  inx
    txa
    and #@(-- num_brickfx)
    tax
    jmp -l
