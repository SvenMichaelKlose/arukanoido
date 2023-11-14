digisound_rate            = @*audio-rate*
digisound_timer_pal       = @(/ (cpu-cycles :pal) digisound_rate)
digisound_timer_ntsc      = @(/ (cpu-cycles :ntsc) digisound_rate)
digisound_rate_fast       = @*audio-rate-fast*
digisound_rate_expanded   = @*audio-rate-expanded*
digisound_timer_fast_pal  = @(/ (cpu-cycles :pal) digisound_rate_fast)
digisound_timer_fast_ntsc = @(/ (cpu-cycles :ntsc) digisound_rate_fast)
digisound_timer_8000_pal  = @(/ (cpu-cycles :pal) digisound_rate_expanded)
digisound_timer_8000_ntsc = @(/ (cpu-cycles :ntsc) digisound_rate_expanded)

; X: Sound index
digi_nmi_start:
    lda @(-- sample_addrs_l),x
    sta rle_play_ptr
    lda @(-- sample_addrs_h),x
    sta @(++ rle_play_ptr)

if @*ultimem?*
    lda has_ultimem
    beq +m
    ldx #<digisound_timer_8000_pal
    ldy #>digisound_timer_8000_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_8000_ntsc
    ldy #>digisound_timer_8000_ntsc
    jmp +n
end

m:  lda @(-- digi_rates),x
    bne +m
    ldx #<digisound_timer_pal
    ldy #>digisound_timer_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_ntsc
    ldy #>digisound_timer_ntsc
    jmp +n
m:  ldx #<digisound_timer_fast_pal
    ldy #>digisound_timer_fast_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_fast_ntsc
    ldy #>digisound_timer_fast_ntsc
n:  jmp nmi_start
