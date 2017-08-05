mouseinit
; For unexpanded Vic-20: Only shows position of mouse on screen, no gfx

        lda     #$1C
        sta     $38     ;basic ends here!
        lda     #$c8
        sta     $37     ;basic ends here!


timers
        ldy #$40      ; enable Timer A free run of both VIAs
        sty $911b
        sty $912b

        lda #$56     ;length of timer low & high byte

        sta $9116     ; load the timer 1 low byte
        sta $9126     ; load the timer low byte counter


        sta $9125     ; start the IRQ timer A (high byte latch)
        ;ldy #10       ; spend some time
        dey           ; before starting the reference timer
        bne *-1
        stx $9115     ; start the reference timer
pointers
        lda #<mouseirq     ; set the raster IRQ routine pointer
        sta $314
        lda #>mouseirq
        sta $315
        lda #$c0
        sta $912e     ; enable Timer A underflow interrupts
        rts

$E404

mouseirq

mousestart                      ;Routine to read NEOS mouse data

nofire

        LDA     $9111
        PHA
        LDA     $9113
        PHA

        LDA     #$FF
        STA     $96

        LDA     $9113           ; Set direction
        AND     #%11000000      ; Bit 5 output
        ORA     #%00100000      ; Bit 5 output
        STA     $9113           ; Set direction
        LDX     #17

mouseloop

        LDA     $9111
        AND     #%11011111      ; Clear bit 5
        STA     $9111           ; Trigger NEOS mouse
        JSR     waitsome

        LDX     #$7F
        STX     $9122   ; Set VIA2 to listen for joystickport
        LDA     $9120
        AND     #0 ;#$80    ; S3  #0 without pin4
        STA     $3
        LDA     $9111
        AND     #%00011100      ; S2, S1, S0
        ASL
        ASL
        ORA     $3      ; Add bit 7
        STA     $3

        LDX     #$FF
        STX     $9122   ; Set VIA2 to listen for keyboard again

        LDA     $9111
        ORA     #%00100000      ; set bit 5
        STA     $9111           ; Trigger NEOS mouse
        LDX     #5
        JSR     waitsome

        LDX     #$7F
        STX     $9122   ; Set VIA2 to listen for joystickport
        LDA     $9120
        AND     #0 ;#$80    ; S3  #0 without pin4
        LSR
        LSR
        LSR
        LSR
        ORA     $3
        STA     $3
        LDA     $9111
        AND     #%00011100      ; S2, S1, S0
        LSR
        LSR
        ORA     $3      ; Add other bits
;        STA     $3
; set negative bit without joy3 signal:
        asl
        clc
        bpl     *+5
        sec                ;compensate for missing bit7
        ora     #%00010000 ;compensate for missing bit3
        ror
        sta     $3
        LDX     #$FF
        STX     $9122   ; Set VIA2 to listen for keyboard again



        INC     $96
        BNE     mousecalc
        STA     $4      ;x-value here
        LDX     #5
        JSR     waitsome
        LDX     #5
        JMP     mouseloop
mousecalc               ; use delta values to calculate new postitions
        PLA
        STA     $9113
        PLA
        STA     $9111


        sec
        lda     $5    ;low byte
        sbc     $4      ;add delta x (signed)
        sta     $5

        sec
        lda     $6    ;low byte
        sbc     $3      ;add delta x (signed)
        sta     $6

        ; For debug in VICE:
;        lda     #$ff
;        sec
;        sbc     $9008
;        sta     xval
;        lda     $9009

;        sta     yval

mouseprint              ;Routine to put mouse x&y on screen

        LDA     $5
        STA     sval
        LDA     #0
        STA     star
        LDA     #24     ;"X"
        JSR     showvalue
        LDA     $6
        STA     sval
        LDA     #6
        STA     star
        LDA     #25     ;"Y"
        JSR     showvalue


        JMP     $eabf     ; return to normal IRQ

waitsome

        DEX
        BNE     waitsome
        RTS

showvalue               ; shows an integer value
        LDX     star
        STA     $1E00,X
        LDA     #"="
        STA     $1E01,X

        LDA     sval
        JSR     div10
        TAY
        JSR     div10
        TAX
        JSR     mult10
        STA     $3
        TYA
        SEC
        SBC     $3      ; tenths
        CLC
        ADC     #48
        STA     $96      ;temp storage
        TXA
        ADC     #48
        LDX     star
        STA     $1E02,X   ; hundreds
        LDA     $96
        STA     $1E03,X   ; hundreds
        TYA     
        JSR     mult10
        STA     $3
        LDA     sval
        SEC
        SBC     $3
        CLC
        ADC     #48
        LDX     star
        STA     $1E04,X   ; 0-9
        LDA     #2
        STA     $9600,X
        STA     $9601,X
        STA     $9602,X
        STA     $9603,X
        STA     $9604,X
        RTS

sval    byte 0
star    byte 0

div10
        lsr
        sta  $4 ;1/2
        lsr
        adc  $4 ;1/4+1/2=3/4
        ror
        lsr
        lsr
        adc  $4 ;3/32+16/32=19/32
        ror
        adc  $4 ;19/64+32/64=51/64
        ror
        lsr
        lsr     ;51/512
        rts

mult10  ; 2+8
        asl
        sta     $4
        asl
        asl
        clc
        adc     $4
        rts
