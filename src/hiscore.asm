__start_hiscore:

hiscore_yc = 16
score_item_size = @(+ num_score_digits 1 3)

txt_hiscore_h1: @(string4x8 "THE FOLLOWING ARE") 255
txt_hiscore_h2: @(string4x8 "THE RECORDS OF THE BRAVEST") 255
txt_hiscore_h3: @(string4x8 "FIGHTERS OF ARUKANOIDO") 255
txt_enter:      @(string4x8 "ENTER YOUR INITIALS !") 255
txt_hiscore:    @(string4x8 "HIGH ")
txt_score:      @(string4x8 "SCORE") 255
txt_round:      @(string4x8 "ROUND") 255
txt_name:       @(string4x8 "NAME") 255
txt_all:        @(string4x8 "ALL") 255
txt_first:      @(string4x8 "1ST") 255
txt_second:     @(string4x8 "2ND") 255
txt_third:      @(string4x8 "3RD") 255
txt_fourth:     @(string4x8 "4TH") 255
txt_fifth:      @(string4x8 "5TH") 255

print_initial_char:
    jsr scrcoladdr
    jsr get_curchar_addr
    ldy #0
    lda (s),y
    jsr print4x8_dynalloc

inc_s:
    inc sl
    bne +r
    inc sh
r:  rts

print_score_heading:
    lda #yellow
    sta curcol
    lda #<txt_score
    ldy #>txt_score
    jsr print_string_ay
    inc curchar

    lda scrx2
    clc
    adc #1
    sta scrx2
    lda #<txt_round
    ldy #>txt_round
    jsr print_string_ay
    inc curchar

    lda scrx2
    clc
    adc #1
    sta scrx2
    lda #<txt_name
    ldy #>txt_name
    jsr print_string_ay
    inc curchar
    rts

hiscore_table:
    jsr blank_screen
    jsr clear_screen
    jsr clear_charset
    lda #1
    sta curchar
    jsr print_scores_and_labels
    jsr draw_credits

    lda #yellow
    sta curcol
    lda #7
    sta scrx2
    lda playfield_yc
    clc
    adc #6
    sta scry
    lda #<txt_hiscore_h1
    ldy #>txt_hiscore_h1
    jsr print_string_ay
    inc curchar

    inc scry
    inc scry
    lda #2
    sta scrx2
    lda #<txt_hiscore_h2
    ldy #>txt_hiscore_h2
    jsr print_string_ay
    inc curchar

    inc scry
    inc scry
    lda #4
    sta scrx2
    lda #<txt_hiscore_h3
    ldy #>txt_hiscore_h3
    jsr print_string_ay
    inc curchar

    jsr print_hiscores
    jmp unblank_screen

r:  rts
enter_hiscore:
    jsr find_score_item
    bcc -r  ; No new hiscore…

    lda level
    cmp #@(++ doh_level)
    beq +n
    jsr wait_for_silence

n:  lda dl
    pha
    lda dh
    pha

    jsr blank_screen
    jsr clear_screen
    jsr clear_charset
    lda #1
    sta curchar
    jsr print_scores_and_labels

    lda #red
    sta curcol
    lda #5
    sta scrx2
    lda playfield_yc
    clc
    adc #7
    sta scry
    lda #<txt_enter
    ldy #>txt_enter
    jsr print_string_ay
    inc curchar
    jsr print_hiscores

    ;; Enter
    lda #7
    sta tmp4

    lda playfield_yc
    clc
    adc #10
    sta scry
    lda tmp4
    sta scrx2
    jsr print_score_heading

    inc scry
    inc scry

    ;; Find and free entry.
    jsr find_score_item
    ; Get number of bytes to copy.  (tmp * 10)
    lda tmp
    sbc #1
    asl
    sta cl
    asl
    asl
    adc cl
    sta cl
    lda #0
    sta ch
    ; Move items down.
    lda #@(low (- scores_end score_item_size 1))
    sta sl
    lda #@(high (- scores_end score_item_size 1))
    sta sh
    lda #@(low (- scores_end 1))
    sta dl
    lda #@(high (- scores_end 1))
    sta dh
    jsr moveram_backwards

    ;; Fill in new score.
n:  lda #1
    sta tmp4

    pla
    sta dh
    pla
    sta dl

    ; Set round.
    ldy active_player
    lda level,y
    ldy #num_score_digits
    sta (d),y

    ; Clear initials.
    lda #0
    iny
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y

    ; Copy score.
    lda score
    sta sl
    lda @(++ score)
    sta sh
    lda #num_score_digits
    sta cl
    lda #0
    sta ch
    lda dl
    pha
    lda dh
    pha
    jsr moveram
    pla
    sta dh
    pla
    sta dl

    lda #0
    sta tmp5
    lda #0
    sta tmp6

    jsr unblank_screen

    lda level
    cmp #@(++ doh_level)
    beq +l
    lda #snd_hiscore
    jsr play_sound

    jsr paddles_start

    ;; Print input line.
l:  jsr wait_retrace

    ; Save first allocate char of line.
    lda curchar
    pha

    ; Get index into initial.
    lda tmp5
    clc
    adc #@(++ num_score_digits)
    tay

    ; Write initial to score record.
    ldx tmp6
    lda initial_chars,x
    sta (d),y

    ;; Print record.
    lda dl
    pha
    lda dh
    pha
    lda dl
    sta sl
    lda dh
    sta sh
    jsr print_score_round_name
    pla
    sta dh
    pla
    sta dl

    pla
    sta curchar

    lda is_using_paddle
    bne +m

    ;; Handle joystick input.
    ; Fire
l3: lda $9111
    and #joy_fire
    bne +n4
    ; Wait for button release.
l5: lda $9111
    and #joy_fire
    beq -l5
    jmp add_initial
n4: jsr get_joystick
    beq -l3
    clc
    adc tmp6
    sta tmp6
l6: jsr get_joystick
    bne -l6
    jmp +l4

    ;; Test on fire.
m:  jsr test_fire
    bne +o
    ; Wait for button release.
n2: jsr test_fire
    beq -n2

add_initial:
    inc tmp5
    lda tmp5
    cmp #3
    beq +r      ; Three added…
    bne -l

    ;; Select initial via paddle.
o:  lda paddle_value
    clc
    adc old_paddle_value
    ror
    cmp old_paddle_value
    beq -m      ; Paddle didn't move…
    sta old_paddle_value
    jsr neg
    lsr
    lsr
    lsr
    ; Do not go beyond list of available initials.
l4: cmp #num_initial_chars
    bcc +n
    lda #@(-- num_initial_chars)
n:  sta tmp6
    jmp -l

    ; Done.
r:  jsr hiscore_table
    lda #60
    jsr wait
    rts

find_score_item:
    lda #5
    sta tmp
    lda #<scores
    sta dl
    lda #>scores
    sta dh
    lda score
    sta sl
    lda @(++ score)
    sta sh
l:  ldx #@(-- num_score_digits)
    jsr bcd_cmp
    bcs +found
    lda #10
    jsr add_db
    dec tmp
    bne -l
    clc
    rts
found:
    sec
    rts

print_hiscores:
    lda #4
    sta tmp4

    lda playfield_yc
    clc
    adc #16
    sta scry
    lda tmp4
    clc
    adc #6
    sta scrx2
    jsr print_score_heading

    lda #white
    sta curcol
    lda playfield_yc
    clc
    adc #18
    sta scry
    lda #5
    sta c
    lda #<txt_first
    sta sl
    lda #>txt_first
    sta sh

l:  lda tmp4
    sta scrx2
    jsr print_string
    inc curchar
    inc scry
    inc scry

    ldy #0
m:  lda (s),y
    bmi +n
    jsr inc_s
    jmp -m

n:  jsr inc_s
    dec c
    bne -l

    lda playfield_yc
    clc
    adc #18
    sta scry
    lda #<scores
    sta sl
    lda #>scores
    sta sh
    lda #5
    sta c
l:  jsr print_score_round_name
    inc scry
    inc scry
    dec c
    bne -l

    rts

;;; Print scores and initials.
print_score_round_name:
    lda tmp4
    clc
    adc #4
    sta scrx2
    jsr print_score_string
    inc curchar
    jsr scrcoladdr
    jsr get_curchar_addr

    lda #num_score_digits
    jsr add_sb

    ; Print round number.
n:  lda tmp4
    clc
    adc #15
    sta scrx2
    ldy #0
    lda (s),y
    jsr inc_s
    ldx #0
m:  sec
    sbc #10
    inx
    beq -m
    bcs -m
    clc
    adc #10
    dex
    beq +n
    pha
    txa
    clc
    adc #score_char0
    jsr print4x8_dynalloc
    pla
n:  pha
    lda tmp4
    clc
    adc #16
    sta scrx2
    pla
    clc
    adc #score_char0
    jsr print4x8_dynalloc
    inc curchar

    ; Print initials.
    lda tmp4
    clc
    adc #19
    sta scrx2
    jsr print_initial_char
    jsr print_initial_char
    jsr print_initial_char
    inc curchar
    rts

initial_chars:
    @(string4x8 "ABCDEFGHIJKLMNOPQRSTUVWXYZ.! ")
initial_chars_end:
num_initial_chars = @(- initial_chars_end initial_chars)

scores:
    0 0 5 0 0 0 5 @(string4x8 "SSB")
    0 0 4 5 0 0 4 @(string4x8 "SND")
    0 0 4 0 0 0 3 @(string4x8 "TOR")
    0 0 3 5 0 0 2 @(string4x8 "ONJ")
    0 0 3 0 0 0 1 @(string4x8 "AKR")
scores_end:

__end_hiscore:
