add_sb:
    clc
    adc s
    sta s
    bcc +n
    inc @(++ s)
n:  rts

add_db:
    clc
    adc d
    sta d
    bcc +n
    inc @(++ d)
n:  rts
