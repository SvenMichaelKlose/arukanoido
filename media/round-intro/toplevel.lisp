(defvar video_width (* 15 4))
(defvar video_height (* 32 8))
(defvar edges_width video_width)
(defvar edges_height video_height)
(defvar *dithering* nil)
(defvar *errdec* 0) ;0.222222) ;0.333333)

(defconstant +bw-palette+
             '((  0   0   0)
               (255 255 255)))

(defconstant +vic20-micropalette+
             '((  0   0   0)    ; Black
               (#xb6  #x1f  #x21)    ; Red
               (#x4d  #xf9 #xff)    ; Cyan
               (#x1a   #x34 #xff)))    ; Blue
;               (68  226  55)))  ; Green

;"#CA5400"
;"#E9B072"
;"#E79293"
;"#9AF7FD"
;"#E09FFF"
;"#8FE493"
;"#8290FF"
;"#E5DE85"

(defconstant +vic20-palette+
             '((  0   0   0)    ; Black
               (255 255 255)    ; White
               (#xb6  #x1f  #x21)    ; Red
               (#x4d  #xf9 #xff)    ; Cyan
               (#xb4  #x3f #xff)    ; Purple
               (#x44  #xe2  #x37)    ; Green
               (#x1a   #x34 #xff)    ; Blue
               (#xdc #xd7  #x1b)))  ; Yellow


(defconstant +vic20-palette-ext+
             (+ +vic20-palette+
                '((233 176 114)     ; Light Brown
                  (231 146 147)     ; Light Red
                  (154 247 253)     ; Light Cyan
                  (224 159 255)     ; Light Purple
                  (143 228 147)     ; Light Green
                  (130 144 255)     ; Light Blue
                  (229 222 133))))  ; Light Yellow

(defun get-pixel-luminance (pixels x y)
  (alet (* 4 (+ 0 x (* y video_width)))
    (*math.floor (+ 0 (* (aref pixels !) 1) ;0.2989)
                      (* (aref pixels (+ 1 !))1) ; 0.587)
                      (* (aref pixels (+ 2 !))1))))) ; 0.114)))))

(defun get-pixel (pixels x y)
  (alet (* 4 (+ 0 x (* y video_width)))
    (list (aref pixels !)
          (aref pixels (+ 1 !))
          (aref pixels (+ 2 !)))))

(defun set-pixel (pixels x y r g b)
  (alet (* 4 (number+ x (* y edges_width)))
    (= (aref pixels !) r)
    (= (aref pixels (+ 1 !)) g)
    (= (aref pixels (+ 2 !)) b)))

(defvar oer 0)
(defvar oeg 0)
(defvar oeb 0)

(defun find-color (palette r g b)
  (with (err   1024
         nerr  nil
         c     nil
         i     0
         fi    0
         er nil
         eg nil
         eb nil)
    (adolist palette
      (= er (- (number+ r oer) !.))
      (= eg (- (number+ g oeg) .!.))
      (= eb (- (number+ b oeb) ..!.))
      (= nerr (sqrt (number+ (* er er) (* eg eg) (* eb eb))))
      (when (< nerr err)
        (= err nerr)
        (= c !)
        (= fi i))
      (++! i))
    (unless (eq *dithering* 'none)
      (= oer (+ (* *errdec* oer) (- r c.)))
      (= oeg (+ (* *errdec* oeg) (- g .c.)))
      (= oeb (+ (* *errdec* oeb) (- b ..c.))))
    fi))

(defun reset-dithering ()
  (= oer 0)
  (= oeg 0)
  (= oeb 0))

(defun draw-multicolor-array (p pixels w h palette)
  (dotimes (x w)
    (dotimes (y h)
      (apply #'set-pixel pixels x y (elt palette (aref p (number+ (* x h) y)))))))

(defun draw-multicolor (pixels w h palette)
  (let p (make-array)
    (dotimes (x w)
      (reset-dithering)
      (dotimes (y h)
        (= (aref p (number+ (* x h) y)) (apply #'find-color palette (get-pixel pixels x y)))))
    p))

(defun draw-hires (pixels pixels2 w h)
  (dotimes (x w)
    (reset-dithering)
    (dotimes (y h)
      (apply #'set-pixel pixels2 x y (cdr (apply #'find-color +bw-palette+ (alet (get-pixel-luminance pixels x y)
                                                                             (list ! ! !))))))))

(defun get-option (elm)
  (aref elm.options elm.selected-index).value)

(defun draw (video ctx ctx2 w h)
  (ctx.draw-image video 0 0 w h)
  (= ctx.fill-style "#000")
  (ctx.fill-rect 0 0 w 30)
  (= ctx.fill-style "#fff")
;  (ctx.fill-rect 0 0 w 100)
  (ctx2.draw-image video 0 0 w h)
  (= *dithering* (make-symbol (upcase (get-option (document.query-selector ".dithering")))))
  (with (data     (ctx.get-image-data 0 0 w h)
         pixels   data.data
         data2    (ctx2.get-image-data 0 0 edges_width edges_height)
         pixels2  data2.data)
    (= oer oeg oeb 0)
    (? (equal "multi" (get-option (document.query-selector ".mode")))
       (alet (get-option (document.query-selector ".model"))
         (?
           (equal "vic20-pal4" !)
             (alet (draw-multicolor pixels w h +vic20-micropalette+)
               (draw-multicolor-array ! pixels2 w h +vic20-micropalette+)
               nil)
           (equal "vic20-pal" !)
             (draw-multicolor pixels w h +vic20-palette+)
           (equal "vic20-palext" !)
             (draw-multicolor pixels w h +vic20-palette-ext+)
           (equal "c64" !)
             (draw-multicolor pixels w h +c64-palette+)
           (error "Unknown model ~A." !)))
       (draw-hires pixels pixels2 w h))
    (ctx2.put-image-data data2 0 0)
    (= *former-pixels* pixels)))

(defun draw-update (video ctx ctx2 w h frame)
  (= video.src (+ "frames/file0" frame ".png"))
  (= video.onload [0 (draw video ctx ctx2 w h)
                       (when (< frame 552)
                         (set-timeout [0 (draw-update video ctx ctx2 w h (++ frame))]
                                      0))]))

(defun set-image-smoothing (x v)
  (= x.image-smoothing-enabled v)
  (= x.moz-image-smoothing-enabled v)
  (= x.webkit-image-smoothing-enabled v)
  (= x.ms-image-smoothing-enabled v))

(defun setup-canvas (video canvas canvas2)
  (= canvas.width video_width)
  (= canvas.height video_height)
  (= canvas.style.width "0")
  (= canvas.style.height "0")
  (= canvas2.width edges_width)
  (= canvas2.height edges_height)
  (= canvas2.style.width (+ (* 8 edges_width) "px"))
  (= canvas2.style.height (+ (* 3 edges_height) "px"))
  (set-image-smoothing (canvas.get-context "2d") t)
;  (set-image-smoothing (canvas2.get-context "2d") t)
          (= video.style.width "50%")
          (= video.style.height "50%")
  (draw-update video
               (canvas.get-context "2d")
               (canvas2.get-context "2d")
               video_width video_height
               102))

((j-query window).load
    #'(()
        (= document.body.style "background: black; color: white;")
          (setup-canvas (document.query-selector "img")
                        (document.query-selector ".input")
                        (document.query-selector ".edges"))))
