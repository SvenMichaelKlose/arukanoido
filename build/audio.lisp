(var *audio-rate* 4000)
(var *audio-rate-fast* 6000)

(const *audio-files*
       '(
         "lost-ball"
;        "catch"     ; Play beginning of reflection_low instead.
         "doh-dissolving"
         "explosion"
         "reflection-doh"
         "game-over"
         "extra-life"
         "extension"
         "break-out"
         "laser"
         "round-intro"
         "reflection-high"
         "reflection-low"
         "reflection-med"
         "final"
         "doh-intro"
         "round-start"
))

(fn make-filtered-wav (name rate)
  (sb-ext:run-program "/usr/bin/sox"
                      `(
;                        "-v 0.9"
                        ,(+ "media/audio/" name ".wav")
                        ,(+ "obj/" name ".filtered.wav")
;                        "bass" "12"
                        "lowpass" ,(princ (half rate) nil)
;"compand" "0.3,1" "6:-70,-60,-20" "-5" "-90" ; podcast
;"compand" "0.1,0.3" "-60,-60,-30,-15,-20,-12,-4,-8,-2,-7" "-2" ; voice/music
;"compand" "0.01,1" "-90,-90,-70,-70,-60,-20,0,0" "-5" ; voice/radio
                        )
                       :pty cl:*standard-output*))

(fn downsampled-audio-name (name)
  (+ "obj/" name ".downsampled.wav"))

(fn make-conversion (name rate)
  (sb-ext:run-program "/usr/bin/sox"
                      (list (+ "obj/" name ".filtered.wav")
                            "-c" "1"
                            "-b" "16"
                            "-r" (princ rate nil)
                            (downsampled-audio-name name))
                      :pty cl:*standard-output*))

(fn trim-wav (x)
  (? (== x. .x.)
     (trim-wav .x)
     x))

(fn read-wav (in)
  (= (stream-track-input-location? in) nil)
  (adotimes 96 (read-byte in))
  (with-queue q
    (awhile (read-word in)
            (queue-list q)
      (enqueue q (bit-xor ! 32768)))))

(fn around (x f m)
  (!= (degree-sin (* (/ 89 65536) x))
    (!= (integer (* ! 65535))
      (* (integer (/ ! f)) m))))

(fn wav2mon (out in f)
  (@ (! in)
    (write-word (bit-xor (around ! f f) 32768) out)))

(fn wav2raw (out in f m)
  (with-queue q
    (@ (! in)
      (enqueue q (around ! f m)))
    (@ (i (reverse (trim-wav (reverse (trim-wav (queue-list q))))))
      (write-byte (+ i (* 11 16)) out))))

(fn smallest (x)
  (let v 65535
    (@ (i x v)
      (when (< i v)
        (= v i)))))

(fn biggest (x)
  (let v 0
    (@ (i x v)
      (when (> i v)
        (= v i)))))

(fn num-singles (x &optional (n 1))
  (?
    (not x)          n
    (not .x)         n
    (& (< n 7)
       (== 16 (bit-and x. #xf0) (bit-and .x. #xf0)))
                     (num-singles .x (++ n))
    n))

(fn rle-compress2 (x)
  (?
    (not x)          nil
    (not .x)         (list (>> x. 4) (bit-and x. 15))
    (== 16 (bit-and x. #xf0))
                    (!= (num-singles x)
                      (+ (list (+ ! 8))
                         (@ [bit-and _ 15] (subseq x 0 !))
                         (rle-compress2 (nthcdr ! x))))
    (. (>> x. 4)
       (. (bit-and x. 15)
          (rle-compress2 .x)))))

(fn rle-compress (x &optional (n 1))
  (?
    (not x)          nil
    (not .x)         (list (bit-and x. 15))
    (& (< n 7)
       (== x. .x.))  (rle-compress .x (++ n))
    (. (+ (* n 16) (bit-and x. 15)) (rle-compress .x))))

(fn packed (x)
  (@ [+ (<< (| ._. 0) 4) (| _. 0)] (group x 2)))

(fn convert-wavs (x d m)
  (@ (i x)
       (with (wav (with-input-file in (+ "obj/" i ".downsampled.wav")
                    (read-wav in))
              lo  (smallest wav)
              hi  (biggest wav)
              rat (/ 65535 (- hi lo))
              lwav  (@ #'integer (@ [* _ rat]
                                    (@ [- _ lo] wav))))
         (with-output-file out (+ "obj/" i "." (string m) ".raw")
           (wav2raw out lwav d m))
         (with-output-file out (+ "obj/" i "." (string m) ".mon")
           (wav2mon out lwav d))
         (with-output-file out (+ "obj/" i "." (string m) ".pac")
           (@ (i (packed (@ [char-code (bit-and _ 15)] (string-list (fetch-file (+ "obj/" i "." (string m) ".raw"))))))
             (write-byte i out)))
;         (with-output-file out (+ "obj/" i "." (string m) ".rle")
;           (@ (i (rle-compress (@ #'char-code (string-list (fetch-file (+ "obj/" i "." (string m) ".raw"))))))
;             (write-byte i out))
;           (write-byte 0 out))
         (with-output-file out (+ "obj/" i "." (string m) ".rle")
           (@ (i (packed (rle-compress2 (rle-compress (@ #'char-code (string-list (fetch-file (+ "obj/" i "." (string m) ".raw"))))))))
             (write-byte i out))
           (write-byte 0 out))
         (exomize-stream (+ "obj/" i "." (string m) ".raw") (+ "obj/" i "." (string m) ".exm")))))

(fn make-arcade-sounds ()
  (@ (i (+ *audio-files*))
    (print i)
    (!= (? (in? i "doh-dissolving")
           *audio-rate-fast*
           *audio-rate*)
      (make-filtered-wav i !)
      (make-conversion i !)))
;  (convert-wavs *audio-files* 32768 8)    ; 1 bit
  (convert-wavs *audio-files* 16384 4)     ; 2 bits
  (convert-wavs *audio-files* 8192 2)      ; 3 bits
  (convert-wavs *audio-files* 4096 1)      ; 4 bits
)
