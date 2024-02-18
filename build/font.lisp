(fn packed-font ()
  (assemble-files "obj/font-4x8.bin" "media/font-4x8.asm")
  (mapcan [maptimes #'((i)
                        (+ (elt _ i) (<< (elt _ i) 4)))
                    8]
          (group (@ #'char-code (string-list (fetch-file "obj/font-4x8.bin")))
                 8)))

(fn make-font ()
  (put-file "obj/font-4x8-packed.bin" (list-string (@ #'code-char (packed-font)))))

(fn ascii2pixcii (x)
  (@ [?
       (== 32 (char-code _))  (code-char 255)
       (alpha-char? _)        (code-char (+ (- (char-code _) (char-code #\A)) (get-label 'framechars)))
       _]
     (string-list x)))

(fn string4x8 (x)
  (@ [- (char-code _) 32] (string-list x)))
