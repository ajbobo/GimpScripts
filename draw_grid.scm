; DrawGrid script.
; Draws a grid on the image in a color that the user specifies
; This may not be as helpful for drawing as the Snap to Grid option, but it makes the grid visible in the file 

(define (script-fu-ajbobo-drawgrid img drawable gridwidth gridheight drawvertical drawhorizontal gridcolor)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  (gimp-context-set-brush "pixel (1x1 square)")
  (gimp-context-set-foreground gridcolor)
  (let* ((totalwidth (car (gimp-image-width img)))
         (totalheight (car (gimp-image-height img)))
         (curxloc gridwidth)
         (curyloc gridheight)
         (array (make-vector 4 'double))
         (newlayer (car (gimp-layer-new img totalwidth totalheight 1 "Grid" 100 0)))
         (activelayer (car (gimp-image-get-active-layer img)))
        )
 
        ; Add the new layer (created above) to the image and clear it (should be transparent)
        (gimp-image-add-layer img newlayer -1)
        (gimp-edit-clear newlayer)
        
        ; Draw vertical lines
        (if (= drawvertical TRUE)
            (while (< curxloc totalwidth)
                   (vector-set! array 0 curxloc)
                   (vector-set! array 1 0)
                   (vector-set! array 2 curxloc)
                   (vector-set! array 3 (- totalheight 1))
                   (gimp-pencil newlayer 4 array)
                   (set! curxloc (+ curxloc gridwidth))
            )
        )

        ; Draw horizontal lines
        (if (= drawhorizontal TRUE)
            (while (< curyloc totalheight)
                   (vector-set! array 0 0)
                   (vector-set! array 1 curyloc)
                   (vector-set! array 2 (- totalwidth 1))
                   (vector-set! array 3 curyloc)
                   (gimp-pencil newlayer 4 array)
                   (set! curyloc (+ curyloc gridheight))
            )
        )

        ; Set the active layer back to the one that was active before this was called
        (if (not (= activelayer -1))
            (gimp-image-set-active-layer img activelayer)
        )
  )
  

  ; Restore previous settings and end the undo group
  (gimp-selection-none img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  
  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-drawgrid"
  _"_Draw Grid"
  "DrawGrid"
  "A.J. Bobo"
  "copyright 2011"
  "March 28, 2011"
  ""
  SF-IMAGE		"Input Image"			0
  SF-DRAWABLE	"Input Drawable"		0
  SF-VALUE		"Grid Width"			"25"
  SF-VALUE		"Grid Height"			"25"
  SF-TOGGLE	"Draw Vertical Lines"		TRUE
  SF-TOGGLE	"Draw Horizonal Lines"	TRUE
  SF-COLOR		"Color"				'(204 204 204)
)

(script-fu-menu-register "script-fu-ajbobo-drawgrid"
  _"<Image>/A.J.Bobo"
)