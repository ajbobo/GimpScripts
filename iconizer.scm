; Iconizer script.
; Takes an image and makes an Icon

(define (script-fu-ajbobo-iconizer img drawable finalwidth finalheight truetransparent threshold)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  ; Crop the image to the selected area - do nothing if there is no selection
  (let* ((fullselection (gimp-selection-bounds img))
         (issel (car fullselection))
         (selx (cadr fullselection))
         (sely (caddr fullselection))
         (selwidth (- (car (cdddr fullselection)) selx))
         (selheight (- (cadr (cdddr fullselection)) sely))
        )
        (if (= issel 1)
            (gimp-image-crop img selwidth selheight selx sely)
        )
  )

  (if (= truetransparent FALSE) 
      (begin ; Create old-style indexed bitmap
            ; Change the image to indexed color mode
            (gimp-image-convert-indexed img NO-DITHER MAKE-PALETTE 256 0 0 "")

            ; Find the background color - use the color at point (0,0) in the image
            ; Convert it from a list of INT32s to an array of INT8s (so it can be compared to the colormap)
            (let* ((bgcolor (car (gimp-image-pick-color img drawable 0 0 0 0 0)))
                   (clearcolor (make-vector 3 'byte))
                  )
                  (vector-set! clearcolor 0 (car bgcolor))
                  (vector-set! clearcolor 1 (cadr bgcolor))
                  (vector-set! clearcolor 2 (caddr bgcolor))

                  ; Search through the colormap to find the index of the background color
                  (let* ((fullmap (gimp-image-get-colormap img))
                         (mapsize (/ (car fullmap) 3))
                         (themap (cadr fullmap))
                         (curindex (- mapsize 1))
                         (colindex -1)
                        )
                        (while (>= curindex 0)
                               (if (and 
                                       (= (vector-ref clearcolor 0) (vector-ref themap (+ (* curindex 3) 0)))
                                       (= (vector-ref clearcolor 1) (vector-ref themap (+ (* curindex 3) 1)))
                                       (= (vector-ref clearcolor 2) (vector-ref themap (+ (* curindex 3) 2)))
                                   )
                                   (set! colindex curindex)
                               )
                               (set! curindex (- curindex 1))
                        )
                        (if (> colindex 0) 
                            (begin
                                  (vector-set! themap (+ (* colindex 3) 0) 192)
                                  (vector-set! themap (+ (* colindex 3) 1) 192)
                                  (vector-set! themap (+ (* colindex 3) 2) 192)
                                  (gimp-image-set-colormap img (car fullmap) themap)
                            )
                        )
                  )
            )
      )
      (begin ; Create new image with true transparency
            ; Find the background color - use the color at point (0,0) in the image
            ; Do I still need to convert it?
            (let* ((bgcolor (car (gimp-image-pick-color img drawable 0 0 0 0 0)))
                  )
                  (gimp-by-color-select drawable bgcolor threshold CHANNEL-OP-REPLACE TRUE FALSE 0 FALSE)
                  (gimp-layer-add-alpha drawable) ; edit-clear will fill with background color if there's no alpha channel
                  (gimp-edit-clear drawable) 
            )
      )
  )

  ; Remove the selection - transform-scale command works better without it
  (gimp-selection-none img)

  ; I used this before - but it seems slow. I don't remember why I used it instead of image-scale-full
  ;(gimp-drawable-transform-scale drawable 0 0 finalwidth finalheight TRANSFORM-FORWARD INTERPOLATION-CUBIC 1 3 1) 

  ; Resize the image
  (gimp-image-scale-full img finalwidth finalheight INTERPOLATION-CUBIC)
  (gimp-image-crop img finalwidth finalheight 0 0)
  (if (= truetransparent FALSE)
      (gimp-image-flatten img) ; The image has to be flattened before a bitmap can be saved
  )

  ; Restore previous settings and end the undo group
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-iconizer"
  _"_Iconizer"
  "Iconizer"
  "A.J. Bobo"
  "copyright 2008"
  "December 22, 2008"
  "RGB*"
  SF-IMAGE		"Input Image"		0
  SF-DRAWABLE	"Input Drawable"		0
  SF-VALUE		"Final Width"		"64"
  SF-VALUE		"Final Height"		"64"
  SF-TOGGLE		"True Transparency"	TRUE
  SF-ADJUSTMENT	"Selection Threshold"	'(100 0 255 1 10 0 SF-SLIDER)
)

(script-fu-menu-register "script-fu-ajbobo-iconizer"
  _"<Image>/A.J.Bobo"
)