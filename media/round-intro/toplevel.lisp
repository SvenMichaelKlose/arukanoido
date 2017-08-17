(defvar video_width (* 21 4))
(defvar video_height (* 22 8))
(defvar edges_width video_width)
(defvar edges_height video_height)
(defvar *dithering* nil)
(defvar *errdec* 0.222222) ;0.333333)

(defconstant +bw-palette+
             '((  0   0   0)
               (255 255 255)))

(defconstant +vic20-micropalette+
             '((  0   0   0)    ; Black
;                  (231 146 147)     ; Light Red
               (182  31  33)    ; Red
               (77  240 255)    ; Cyan
               (68  226  55)))  ; Green

(defconstant +vic20-palette+
             '((  0   0   0)    ; Black
               (255 255 255)    ; White
               (182  31  33)    ; Red
               (77  240 255)    ; Cyan
               (180  63 255)    ; Purple
               (68  226  55)    ; Green
               (26   52 255)    ; Blue
               (220 215  27)))  ; Yellow


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

(defun draw-new (video ctx ctx2 w h)
  (draw video ctx ctx2 w h))

(defun draw-update (video ctx ctx2 w h)
  (set-timeout [draw-update video ctx ctx2 w h] (/ 1000 *fps*))
  (draw-new video ctx ctx2 w h))

(defvar *started?* nil)

(defun set-image-smoothing (x v)
  (= x.image-smoothing-enabled v)
  (= x.moz-image-smoothing-enabled v)
  (= x.webkit-image-smoothing-enabled v)
  (= x.ms-image-smoothing-enabled v))

(defun setup-canvas (video canvas canvas2)
  (video.add-event-listener "play"
                            [0 (unless *started?*
                                 (= *started?* t)
                                 (= canvas.width video_width)
                                 (= canvas.height video_height)
                                 (= canvas.style.width "0")
                                 (= canvas.style.height "0")
                                 (= canvas2.width edges_width)
                                 (= canvas2.height edges_height)
                                 (= canvas2.style.width (+ (/ (* 22 8 6) 3) "px"))
                                 (= canvas2.style.height (+ (* 23 8) "px")))
                               (set-image-smoothing (canvas.get-context "2d") t)
                               (set-image-smoothing (canvas2.get-context "2d") t)
                               (draw-update this
                                            (canvas.get-context "2d")
                                            (canvas2.get-context "2d")
                                            video_width video_height)]
                            false))

((j-query window).load
    #'(()
        (= document.body.style "background: black; color: white;")
        (let video (document.query-selector "video")
          (= video.src "video.mp4") ;(window.*U-R-L.create-object-u-r-l localMediaStream))
          (= video.onloadedmetadata #'((e)))
          (= video.style.width "50%")
          (= video.style.height "50%")
          (setup-canvas video
                        (document.query-selector ".input")
                        (document.query-selector ".edges")))))
