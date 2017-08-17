(defun emit-page (_)
  (make-html-script "index.html" _
                    :external-script "http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"
                    :body '(
                            (canvas :class "edges" 
                                    :style "" "")
                            (br)
                            (input :type "text" :size "40" :class "msg" "")
                            (br)
                            (input :type "text" :size "40" :class "msg2" "")
                            (div
                              (select :class "model"
                                (option :value "vic20-pal4" "VIC-20 PAL 4 colors")
                                (option :value "vic20-pal" "VIC-20 PAL 8 colors")
                                (option :value "vic20-palext" "VIC-20 PAL 16 colors")
                                (option :value "c64" "C64"))
                              (select :class "mode"
                                (option :value "multi" "multicolor")
                                (option :value "hires" "hires"))
                              (select :class "dithering"
                                (option :value "continuous" "dithering")
                                (option :value "none" "no dithering")))
                            (div
                              (canvas :class "input" 
                                ""))
                            (img))))

(make-project "CBM colored webcam"
              '("toplevel.lisp")
              :transpiler  *js-transpiler*
              :emitter     #'emit-page)
(quit)
