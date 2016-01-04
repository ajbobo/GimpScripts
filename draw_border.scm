; Draw Border script
; Draws a border around the current layer

(define (script-fu-ajbobo-draw-border img drawable linewidth color)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  ; Draw progressively small borders around the drawable(layer)
  (gimp-context-set-foreground color)
  (gimp-context-set-brush "pixel (1x1 square)")
  (let* ((count 0)
         (left 0)
         (top 0)
         (width (- (car (gimp-drawable-width drawable)) 1))
         (height (- (car (gimp-drawable-height drawable)) 1))
         (array (make-vector 16 'double))
        )
        (while (< count linewidth)
               (begin
                     ; Top-left to top-right
                     (vector-set! array 0 left) 
                     (vector-set! array 1 top)
                     (vector-set! array 2 width)
                     (vector-set! array 3 top)

                     ; Top-right to bottom-right
                     (vector-set! array 4 width) 
                     (vector-set! array 5 top) 
                     (vector-set! array 6 width) 
                     (vector-set! array 7 height) 

                     ; Bottom-right to bottom-left
                     (vector-set! array 8 width) 
                     (vector-set! array 9 height) 
                     (vector-set! array 10 left) 
                     (vector-set! array 11 height) 

                     ; Bottom-right to top-left
                     (vector-set! array 12 left) 
                     (vector-set! array 13 height) 
                     (vector-set! array 14 left) 
                     (vector-set! array 15 top) 
                     
                     (gimp-pencil drawable 16 array)

                     (set! count (+ count 1))
                     (set! left (+ left 1))
                     (set! top (+ top 1))
                     (set! width (- width 1))
                     (set! height (- height 1))
               )
        )
  )

  ; Restore previous settings and end the undo group
  (gimp-selection-none img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-draw-border"
  _"_Draw Border"
  "Draw Border"
  "A.J. Bobo"
  "copyright 2007"
  "November 21, 2007"
  ""
  SF-IMAGE	"Input Image"		0
  SF-DRAWABLE	"Input Drawable"	0
  SF-VALUE	"Width"			"1"
  SF-COLOR	"Color"			'(0 0 0)
)

(script-fu-menu-register "script-fu-ajbobo-draw-border"
  _"<Image>/A.J.Bobo"
)