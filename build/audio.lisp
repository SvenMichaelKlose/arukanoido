;(cl:proclaim '(cl:optimize (cl:speed 0) (cl:space 0) (cl:safety 3) (cl:debug 3)))
(var *audio-rate* 4000)
(var *audio-rate-fast* 6000)

(const *audio-files*
       '(
         ("lost-ball" 3)
;        "catch"     ; Play beginning of reflection_low instead.
         ("doh-dissolving")
         ("explosion" 3)
         ("reflection-doh")
         ("game-over" 3)
         ("extra-life" 3)
         ("extension" 3)
         ("break-out" 3)
         ("laser" 2)
         ("round-intro" 2)
         ("reflection-high" 4)
         ("reflection-low" 4)
         ("reflection-med" 4)
         ("final" 4)
         ("doh-intro" 4)
         ("round-start" 2)
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

(fn around (x f)
  (!= (degree-sin (* (/ 89 65536) x))
    (* (* (integer (/ (* ! 16) f)) f) 4096)))

(fn wav2mon (out in f)
  (@ (! in)
    (write-word (bit-xor (around ! f) 32768) out)))

(fn wav2raw (out in f)
  (with-queue q
    (@ (! in)
      (enqueue q (around ! f)))
    (@ (i (reverse (trim-wav (reverse (trim-wav (queue-list q))))))
      (write-byte (+ (integer (/ i 4096)) (* 11 16)) out))
    (write-byte 0 out)))

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

(fn convert-wav (i d)
  (with (wav (with-input-file in (+ "obj/" i ".downsampled.wav")
               (read-wav in))
         lo  (smallest wav)
         hi  (biggest wav)
         rat (/ 65535 (- hi lo))
         lwav  (@ #'integer (@ [* _ rat]
                               (@ [- _ lo] wav))))
    (with-output-file out (+ "obj/" i "." (string d) ".raw")
      (wav2raw out lwav d))
    (with-output-file out (+ "obj/" i "." (string d) ".mon")
      (wav2mon out lwav d))
    (with-output-file out (+ "obj/" i "." (string d) ".pac")
      (@ (i (packed (@ [bit-and (char-code _) 15] (string-list (fetch-file (+ "obj/" i "." (string d) ".raw"))))))
        (write-byte i out)))
;    (with-output-file out (+ "obj/" i "." (string m) ".rle")
;      (@ (i (rle-compress (@ #'char-code (string-list (fetch-file (+ "obj/" i "." (string m) ".raw"))))))
;        (write-byte i out))
;      (write-byte 0 out))
    (with-output-file out (+ "obj/" i "." (string d) ".rle")
      (@ (i (packed (rle-compress2 (rle-compress (@ #'char-code (string-list (fetch-file (+ "obj/" i "." (string d) ".raw"))))))))
        (write-byte i out))
      (write-byte 0 out))
    (exomize-stream (+ "obj/" i "." (string d) ".raw") (+ "obj/" i "." (string d) ".exm"))))

(fn make-arcade-sounds ()
  (@ (i (+ *audio-files*))
    (print i.)
    (!= (? (in? i. "doh-dissolving")
           *audio-rate-fast*
           *audio-rate*)
      (make-filtered-wav i. !)
      (make-conversion i. !))
;    (convert-wavs *audio-files* 32768 8)    ; 1 bit
    (? (member 2 .i)
       (convert-wav i. 4))
    (? (member 3 .i)
       (convert-wav i. 2))
    (convert-wav i. 1)))
