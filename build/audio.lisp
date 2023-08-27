;(cl:proclaim '(cl:optimize (cl:speed 3) (cl:space 0) (cl:safety 3) (cl:debug 3)))
;(cl:proclaim '(cl:optimize (cl:speed 3) (cl:space 0) (cl:safety 0) (cl:debug 0)))

(const *audio-files*
       `(
         ("lost-ball"       (2 4000) (1 ,*audio-rate-expanded*))
;        "catch"     ; Play beginning of reflection_low instead.
         ("doh-dissolving"  (1 8000) (1 ,*audio-rate-expanded*))
         ("explosion"       (2 4000) (1 ,*audio-rate-expanded*))
         ("game-over"       (2 4000) (1 ,*audio-rate-expanded*))
         ("extra-life"      (2 4000) (1 ,*audio-rate-expanded*))
         ("extension"       (2 4000) (1 ,*audio-rate-expanded*))
         ("break-out"       (2 4000) (1 ,*audio-rate-expanded*))
         ("laser"           (4 4000) (1 ,*audio-rate-expanded*))
         ("round-intro"     (4 4000) (1 ,*audio-rate-expanded*))
         ("reflection-doh"  (1 ,*audio-rate-expanded*))
         ("reflection-high" (1 4000) (1 ,*audio-rate-expanded*))
         ("reflection-low"  (1 4000) (1 ,*audio-rate-expanded*))
         ("reflection-med"  (1 4000) (1 ,*audio-rate-expanded*))
         ("final"           (1 4000) (1 ,*audio-rate-expanded*))
         ("doh-intro"       (1 4000) (1 ,*audio-rate-expanded*))
         ("round-start"     (4 4000) (1 ,*audio-rate-expanded*))))

(fn make-filtered-wav (name rate)
  (sb-ext:run-program "/usr/bin/sox"
                      `(
                        ,(+ "media/audio/" name ".wav")
                        ,(+ "obj-audio/" name ".filtered.wav")
                        "lowpass" ,(princ (half rate) nil)
                        "highpass" "100"
                        "vol" "7db"
                        )
                       :pty cl:*standard-output*))

(fn downsampled-audio-name (name)
  (+ "obj-audio/" name ".downsampled.wav"))

(fn make-conversion (name rate)
  (sb-ext:run-program "/usr/bin/sox"
                      (list (+ "obj-audio/" name ".filtered.wav")
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

(fn convert-wav (i d rate)
  (with (wav (with-input-file in (+ "obj-audio/" i ".downsampled.wav")
               (read-wav in))
         lo  (smallest wav)
         hi  (biggest wav)
         rat (/ 65535 (- hi lo))
         lwav  (@ #'integer (@ [* _ rat]
                               (@ [- _ lo] wav)))
         name (+ "." (string d) "." (string rate)))
    (with-output-file out (+ "obj-audio/" i name ".raw")
      (wav2raw out lwav d))
    (with-output-file out (+ "obj-audio/" i name ".mon")
      (wav2mon out lwav d))
    (with-output-file out (+ "obj-audio/" i name ".pac")
      (@ (i (packed (@ [bit-and (char-code _) 15] (string-list (fetch-file (+ "obj-audio/" i name ".raw"))))))
        (write-byte i out)))
    (with-output-file out (+ "obj-audio/" i name ".rle")
      (@ (i (packed (rle-compress2 (rle-compress (@ #'char-code (string-list (fetch-file (+ "obj-audio/" i name ".raw"))))))))
        (write-byte i out))
      (write-byte 0 out))
    (exomize-stream (+ "obj-audio/" i name ".raw") (+ "obj-audio/" i name ".exm"))))

(fn make-arcade-sounds ()
  (@ (i *audio-files*)
   (@ (rate '(4000 8000))
     (make-filtered-wav i. rate)
     (make-conversion i. rate)
     (@ (bits '(1 2 3 4))
       (convert-wav i. bits rate)))))
