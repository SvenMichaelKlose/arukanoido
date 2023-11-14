paddles_timer_pal       = @(/ (cpu-cycles :pal) 50)
paddles_timer_ntsc      = @(/ (cpu-cycles :ntsc) 60)

paddles_start:
    jsr nmi_stop
    sei
    jsr wait_retrace
    lda #<paddles_nmi
    sta $318
    lda #>paddles_nmi
    sta $319
    ldx #<paddles_timer_pal
    ldy #>paddles_timer_pal
    lda is_ntsc
    beq +n
    ldx #<paddles_timer_ntsc
    ldy #>paddles_timer_ntsc
n:  jmp nmi_start

paddles_nmi:
    sta paddle_nmi_a
    sty paddle_nmi_y
    lda $9114
    ldy active_player
    lda $9007,y
    sta paddle_value
    lda paddle_nmi_a
    ldy paddle_nmi_y
    rti

paddle_xlat: @(paddle-xlat)
