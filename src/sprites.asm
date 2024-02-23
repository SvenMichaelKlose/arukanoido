init_sprites:
    lda #0
    sta (@(+ free_sprites num_sprites)),y
    ldy #num_sprites
    ldx #is_inactive
l:  tya
    dey
    sta free_sprites,y
    stx sprites_i,y
    bne -l
    rts

; X: sprite index
remove_sprite:
    lda #is_inactive
    sta sprites_i,x
    inx
    lda free_sprites
    sta free_sprites,x
    stx free_sprites
    stx free_sprites
    dex
    rts

; Y: descriptor of new sprite in sprite_inits
; Returns: A: Index of new sprite.
add_sprite:
    stx tmp
    sty tmp2

    ldx free_sprites
    lda free_sprites,x
    sta free_sprites
    dex

    tya
    clc
    adc #<sprite_inits
    sta sl
    lda #>sprite_inits
    adc #0
    sta sh

    ; Make pointer into 'sprites_i'.
    txa
    clc
    adc #sprites_i
    sta dl
    ldy #0
    sty dh

    ; Copy values.
l:  lda (s),y
    sta (d),y
    inc sl
    bne +n
    inc sh
n:  lda dl
    clc
    adc #num_sprites
    sta dl
    cmp #@(+ sprites_pgh num_sprites)
    bcs sprite_added
    bcc -l      ; (jmp)

sprite_added:
    txa
r:  ldx tmp
    ldy tmp2
    rts

remove_sprites_by_type:
    sta tmp
    txa
    pha
    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    and tmp
    beq +n
    jsr remove_sprite
n:  dex
    bpl -l
    pla
    tax
    rts

; Move sprite X up A pixels.
sprite_up:
    jsr neg

; Move sprite X down A pixels.
sprite_down:
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts

; Move sprite X left A pixels.
sprite_left:
    jsr neg

; Move sprite X right A pixels.
sprite_right:
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts

; Find collision with other sprite.
;
; X: sprite index
; A: sprite types to check
;
; Returns:
; C: Clear when a hit was found.
; Y: Sprite index of other sprite.
find_hit:
    sta tmp4
    stx tmp

    lda sprites_dimensions,x
    and #%111
    asl
    asl
    asl
    clc
    adc sprites_x,x
    sta tmp2

    lda sprites_dimensions,x
    and #%111000
    clc
    adc sprites_y,x
    sta tmp3
 
    ldy #@(-- num_sprites)

l:  cpy tmp    ; Skip same sprite.
    beq +n

    lda sprites_i,y     ; Skip inactive sprite.
    and tmp4
    beq +n

    lda sprites_y,y
    cmp tmp3
    bcs +n

    lda sprites_x,y
    cmp tmp2
    bcs +n

    lda sprites_dimensions,y
    and #%00111000
    sec
    sbc #1
    clc
    adc sprites_y,y
    cmp sprites_y,x
    bcc +n

    lda sprites_dimensions,y
    and #%00000111
    asl
    asl
    asl
    sec
    sbc #1
    clc
    adc sprites_x,y
    cmp sprites_x,x
    bcc +n

    clc
    rts

n:  dey
    bpl -l
    sec
    rts

; Find point collision with sprite.
;
; ball_x/ball_y: point coordinates
; A: sprite types to check
;
; Returns:
; C: Clear when a hit was found.
; Y: Sprite index of sprite hit.
find_point_hit:
    sta tmp4

    ; Get opposite corner's coordinates of sprite.
    lda sprites_dimensions,x
    and #%111
    asl
    asl
    asl
    clc
    adc sprites_x,x
    sta tmp2

    lda sprites_dimensions,x
    and #%111000
    clc
    adc sprites_y,x
    sta tmp3

    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and tmp4
    beq +n

    lda ball_x
    cmp sprites_x,y
    bcc +n

    lda ball_y
    cmp sprites_y,y
    bcc +n

    lda sprites_dimensions,y
    and #%111
    asl
    asl
    asl
    sec
    sbc #1
    clc
    adc sprites_x,y
    cmp ball_x
    bcc +n

    lda sprites_dimensions,y
    and #%111000
    clc
    adc sprites_y,y
    sec
    sbc #1
    cmp ball_y
    bcc +n
    clc
    rts

n:  dey
    bpl -l
    sec
    rts

call_sprite_controllers:
    ldx #@(-- num_sprites)
l1: lda sprites_i,x
    bmi +n1             ; Slot unused…
    lda sprites_fl,x
    sta dl
    lda sprites_fh,x
    sta dh
    stx call_controllers_x
m1: jsr +j
    ldx call_controllers_x
n1: dex
    bpl -l1
    rts
j:  jmp (d)
