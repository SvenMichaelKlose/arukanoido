; Replace decorative sprite by new one.
;
; Y: descriptor of new sprite in sprite_inits
; Returns: A: Index of new sprite or 255 if slots are full.
add_sprite:
    stx add_sprite_x
    sty add_sprite_y

    ldy #@(-- num_sprites)
l:  dec sprite_rr
    lda sprite_rr
    and #@(-- num_sprites)
    tax
    lda sprites_i,x     ; Decorative?
    bmi replace_sprite2 ; Yes…
    dey
    bpl -l

    ldx #255

sprite_added:
    txa
r:  ldx add_sprite_x
    ldy add_sprite_y
    rts

replace_sprite2:
    txa
    ldy add_sprite_y
    jmp replace_sprite

; Replace sprite by dummy.
;
; X: sprite index
remove_sprite:
    lda #is_inactive
    sta sprites_i,x
    rts

; Replace sprite by another.
;
; X: sprite index
; Y: low address byte of descriptor of new sprite in sprite_inits
replace_sprite:
    ; Make pointer into init values.
    tya
    clc
    adc #<sprite_inits
    sta s
    lda #>sprite_inits
    adc #0
    sta @(++ s)

    ; Make pointer into 'sprites_i'.
n:  txa
    clc
    adc #sprites_i
    sta d
    ldy #0
    sty @(++ d)

    ; Copy rest of init values.
l:  lda (s),y
    sta (d),y
    inc s
    bne +n
    inc @(++ s)
n:  lda d
    clc
    adc #num_sprites
    sta d
    cmp #@(+ sprites_d num_sprites)
    bcs sprite_added
    jmp -l

remove_sprites:
    ldx #@(-- num_sprites)
l:  jsr remove_sprite
    dex
    bpl -l
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
;
; Returns:
; C: Clear when a hit was found.
; Y: Sprite index of other sprite.
find_hit:
    ; Get opposite corner's coordinates of sprite.
    lda sprites_dimensions,x
    and #%111
    asl
    asl
    asl
    clc
    adc sprites_x,x
    sta find_hit_tmp2

    lda sprites_dimensions,x
    and #%111000
    clc
    adc sprites_y,x
    sta find_hit_tmp3

    stx find_hit_tmp
    ldy #@(-- num_sprites)

l:  cpy find_hit_tmp    ; Skip same sprite.
    beq +n

    lda sprites_i,y     ; Skip inactive sprite.
    bmi +n

    lda sprites_x,y
    cmp find_hit_tmp2
    bcs +n
    lda sprites_dimensions,y
    and #%111
    asl
    asl
    asl
    clc
    adc sprites_x,y
    cmp sprites_x,x
    bcc +n

    lda sprites_y,y
    cmp find_hit_tmp3
    bcs +n
    lda sprites_dimensions,y
    and #%111000
    clc
    adc sprites_y,y
    cmp sprites_y,x
    bcc +n

    clc
    rts

find_hit_next:
n:  dey
    bpl -l
    sec

ok: rts

call_sprite_controllers:
    ldx #@(-- num_sprites)
l1: lda sprites_i,x
    bmi +n1
    lda sprites_fl,x
    sta d
    lda sprites_fh,x
    sta @(++ d)
    stx call_controllers_x
m1: jsr +j
    ldx call_controllers_x
n1: dex
    bpl -l1
    rts
j:  jmp (d)

get_sprite_screen_position:
    lda sprites_x,x
    lsr
    lsr
    lsr
    sta scrx

    lda sprites_y,x
    lsr
    lsr
    lsr
    sta scry
    rts
