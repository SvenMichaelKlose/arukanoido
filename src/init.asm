main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    ; Blank screen.
    lda #0
    sta $9002

    ldx #$ff
    txs

    ; Init VCPU.
    lda #<exec_script
    sta $316
    lda #>exec_script
    sta $317

music_player_size = @(length (fetch-file "sound-beamrider/MusicTester.prg"))
loaded_music_player_end = @(+ loaded_music_player (-- music_player_size))
music_player_end = @(+ music_player (-- music_player_size))

    ; Relocate the music player.
base_loaded_music_player_end = @(- loaded_music_player_end (low (-- music_player_size)))
base_relocated_music_player_end = @(- music_player_end (low (-- music_player_size)))
    lda #<base_loaded_music_player_end
    sta s
    lda #>base_loaded_music_player_end
    sta @(++ s)
    lda #<base_relocated_music_player_end
    sta d
    lda #>base_relocated_music_player_end
    sta @(++ d)
    ldx #@(low music_player_size)
    lda #@(high music_player_size)
    sta @(++ c)
    ldy #@(low (-- music_player_size))
l:  inc $900f
    lda (s),y
    sta (d),y
    dey
    cpy #255
    bne +n
    dec @(++ s)
    dec @(++ d)
n:
    dex
    cpx #255
    bne -l
    dec @(++ c)
    lda @(++ c)
    cmp #255
    bne -l
 
    ; Set default screen origin.
    lda #screen_origin_x
    sta user_screen_origin_x
    lda #screen_origin_y
    sta user_screen_origin_y

    jmp patch
