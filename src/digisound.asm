digisound_rate = @*audio-rate*
digisound_timer_pal = @(/ (cpu-cycles :pal) digisound_rate)
digisound_timer_ntsc = @(/ (cpu-cycles :ntsc) digisound_rate)
digisound_rate_fast = @*audio-rate-fast*
digisound_timer_fast_pal = @(/ (cpu-cycles :pal) digisound_rate_fast)
digisound_timer_fast_ntsc = @(/ (cpu-cycles :ntsc) digisound_rate_fast)
