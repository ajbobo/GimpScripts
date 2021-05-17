; Cropper script.
; Takes an image and crops out a specific portion


(define (script-fu-ajbobo-despeckle-save img drawable radius type black white)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  (let* ((filename (car (gimp-image-get-filename img)))
         (updatedfile (string-append (substring filename 0 (- (string-length filename) 3)) "png"))
        )

    (plug-in-despeckle 1 img drawable radius type black white)
    (file-png-save-defaults 0 img drawable updatedfile updatedfile)
  )


  ; Restore previous settings and end the undo group
  (gimp-selection-none img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-despeckle-save"
  _"_Despeckle & Save"
  "DespeckleAndSave"
  "A.J. Bobo"
  "copyright 2021"
  "May 16 2021"
  ""
  SF-IMAGE	"Input Image"		0
  SF-DRAWABLE	"Input Drawable"	0
  SF-VALUE "Radius" "3"
  SF-OPTION "Type" '("MEDIAN" "ADAPTIVE" "RECURSIVE-MEDIAN" "RECURSIVE-ADAPTIVE")
  SF-VALUE "Black" "7"
  SF-VALUE "White" "248"
)

(script-fu-menu-register "script-fu-ajbobo-despeckle-save"
  _"<Image>/A.J.Bobo"
)
