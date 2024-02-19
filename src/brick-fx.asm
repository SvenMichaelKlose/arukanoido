;;; Animate brick (get next char index of animation).
animate_brick:
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
    clc
r:  rts

;;; Turn silver and golden brick chars into first
;;; animated char.
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

;;; Animate all special bricks on the screen.
do_brick_fx:
    ldx #0
l:  lda screen,x
    jsr animate_brick
    sta screen,x
    lda @(+ 256 screen),x
    jsr animate_brick
    sta @(+ 256 screen),x
    dex
    bne -l
    rts

;;; Add brick to animate.
add_brick_fx:
    ;; Ignore the DOH…
    lda level
    cmp #33
    beq +r

    ;; Check if circular list is full.
    stx tmp
    ldy brickfx_end
    iny
    tya
    and #@(-- num_brickfx)
    cmp brickfx_pos
    beq undo_brick_fx

add_brick_fx2:
    ldx brickfx_end
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

;;; Remove brick animation (on buffer overflow).
;;; TODO: The buffer might be big enouh to render this
;;; procedure unused.  Grab a calculator and check.
undo_brick_fx:
    tay
    lda scr
    pha
    lda @(++ scr)
    pha
    dey
    tya
    and #@(-- num_brickfx)
    tay
    lda brickfx_x,y
    sta scrx
    lda #0
    sta brickfx_x,y
    lda brickfx_y,y
    sta scry
    ;jsr scraddr
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)
    ldy scrx
    lda #bg_brick_special
    sta (scr),y
    pla
    sta @(++ scr)
    pla
    sta scr
    jmp add_brick_fx2

;;; Animate all bricks in the list.
dyn_brick_fx:
    ldx brickfx_pos
l:  txa
    and #@(-- num_brickfx)
    tax
    cpx brickfx_end
    beq -r
    ; Plot new brick.
    lda brickfx_x,x
    beq +n              ; Slot unused (brick removed)…
    sta scrx
    lda brickfx_y,x
    sta scry
    ;jsr scraddr
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)
    ldy scrx
    lda (scr),y
    jsr animate_brick
    bcs +l2
    sta (scr),y
    ; End animation.
    cmp #bg_brick_special
    bne +n
    lda #0
    sta brickfx_x,x
    inc brickfx_pos
    lda brickfx_pos
    and #@(-- num_brickfx)
    sta brickfx_pos
n:  inx
    bpl -l  ; (jmp)

l2: lda #0
    sta brickfx_x,x
    bne -n  ; (jmp)
