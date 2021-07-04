		.global initmusic
		.global domusic
		.global reqSong
		.global curSong

; Set to '1' to include additional features for extra memeory version
.define maxMem 1
		
curEffect = curSong + 1
reqEffect = reqSong + 1

.enum 
MUSIC_NONE = 0
FILLER
TRACK01
TRACK02
TRACK03
TRACK04
TRACK05
TRACK06
TRACK07
TRACK08
TRACK09
TRACK10
TRACK11
TRACK12
TRACK13
TRACK14
TRACK15
TRACK16
TRACK17
MAXSONG
.endenum

