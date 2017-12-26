if @*rom?*
    fill @(- #x7000 *pc*)
end
loaded_music_player: @(fetch-file "sound.bin")
