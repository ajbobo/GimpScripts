; Draw Transparent Border script
; Makes the around the current layer fade to transparent

(define (script-fu-ajbobo-draw-transparent-border img drawable featheramt tempcolor cropimg)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  (let* ((oldselection (gimp-selection-bounds img))
         (issel (car oldselection))
         (selx (cadr oldselection))
         (sely (caddr oldselection))
         (selwidth (- (car (cdddr oldselection)) selx))
         (selheight (- (cadr (cdddr oldselection)) sely))
        )
        ; Invert the selection - creates the border
        (gimp-selection-invert img)

        ; Feather the selection - gives the border the gradient edge
        (gimp-selection-feather img featheramt)

        ; Fill the selection (border) with the temporary color
        (gimp-context-set-foreground tempcolor)
        (gimp-edit-bucket-fill drawable 0 0 100 0 FALSE 0 0)

        ; Recreate the original selection
        (gimp-selection-clear img)
        (gimp-rect-select img selx sely selwidth selheight CHANNEL-OP-ADD FALSE 0)

        ; Shrink the selection so that the full feathered area will be replaced
        (gimp-selection-shrink img (/ featheramt 2))

        ; Replace the temporary color with transparency
        (gimp-selection-invert img)
        (plug-in-colortoalpha 1 img drawable tempcolor)

        ; Crop out large, transparent borders
        (if (= cropimg TRUE)
            (gimp-image-crop img 
               (+ selwidth featheramt 10) 
               (+ selheight featheramt 10) 
               (- selx (+ 5 (/ featheramt 2)))
               (- sely (+ 5 (/ featheramt 2)))
            )
        )
  )

  ; Restore previous settings and end the undo group
  (gimp-selection-clear img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-draw-transparent-border"
  _"_Fading Border"
  "Draw Border"
  "A.J. Bobo"
  "copyright 2008"
  "October 1, 2008"
  ""
  SF-IMAGE	"Input Image"		0
  SF-DRAWABLE	"Input Drawable"	0
  SF-VALUE	"Feather Amount"		"5"
  SF-COLOR	"Temporary Color"		'(0 0 0)
  SF-TOGGLE "Crop Final Image"	TRUE
)

(script-fu-menu-register "script-fu-ajbobo-draw-transparent-border"
  _"<Image>/A.J.Bobo"
)