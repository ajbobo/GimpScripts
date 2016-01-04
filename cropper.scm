; Cropper script.
; Takes an image and crops out a specific portion


(define (script-fu-ajbobo-chart-cropper img drawable)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  ; Crop the image
  (gimp-image-crop img 621 577 173 47)

  ; Restore previous settings and end the undo group
  (gimp-selection-none img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-chart-cropper"
  _"_Cropper"
  "Cropper"
  "A.J. Bobo"
  "copyright 2008"
  "May 29, 2008"
  ""
  SF-IMAGE	"Input Image"		0
  SF-DRAWABLE	"Input Drawable"	0
)

(script-fu-menu-register "script-fu-ajbobo-chart-cropper"
  _"<Image>/A.J.Bobo"
)