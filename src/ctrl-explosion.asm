;;; Turn obstacle into an explosion.
make_explosion:
    lda #0
    sta sprites_i,x
    sta sprites_pgl,x
    sta sprites_pgh,x
    lda sprites_x,x
    and #$fe
    sta sprites_x,x
    lda #<gfx_explosion
    sta sprites_gl,x
    lda #>gfx_explosion
    sta sprites_gh,x
    lda #@(+ multicolor yellow)
    sta sprites_c,x
    lda #<ctrl_explosion
    sta sprites_fl,x
    lda #>ctrl_explosion
    sta sprites_fh,x
    rts

;;; Play animation, then remove it.
ctrl_explosion:
    lda framecounter
    and #3
    bne +n
    lda sprites_gl,x
    clc
    adc #16
    sta sprites_gl,x
    lda sprites_gh,x
    adc #0
    sta sprites_gh,x
    lda sprites_gl,x
    cmp #<gfx_explosion_end
    bne +n
    jmp remove_sprite
n:  rts
