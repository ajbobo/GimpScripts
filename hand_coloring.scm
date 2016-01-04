; Hand-coloring script
; Keeps the selected area colored - changes the rest to B&W

(define (script-fu-ajbobo-hand-color-selection img drawable featheramt desaturatemode transparency)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  (let* ((activelayer (car (gimp-image-get-active-layer img)))
         (newlayer (car (gimp-layer-new-from-drawable activelayer img) )) ; Duplicate the layer
         (newmask (car (gimp-layer-create-mask newlayer ADD-WHITE-MASK))) ; Create the Layer Mask
         (selection (car (gimp-selection-save img))) ; Save the current selection
         (opacity (- 255 transparency))
         (fillcolor (list opacity opacity opacity))
        )

        ; Remove the current selection (it will be restored later)
        (gimp-selection-none img)

        ; Add the new layer and its mask to the image and make it active
        (gimp-image-add-layer img newlayer -1)
        (gimp-image-set-active-layer img newlayer)
        (gimp-layer-add-mask newlayer newmask)

        ; Make the new layer black and white
        (gimp-drawable-set-name newlayer "Grayscale")
        (gimp-desaturate-full newlayer desaturatemode)

        ; Restore the selection and feather it
        (gimp-selection-load selection)
        (gimp-selection-feather img featheramt)
        (gimp-image-remove-channel img selection)

        ; Fill the selected area in the Layer Mask with the transparent color
        (gimp-context-set-foreground fillcolor)
        (gimp-edit-bucket-fill newmask 0 0 100 0 FALSE 0 0)        
  )

  ; Restore previous settings and end the undo group
  (gimp-selection-clear img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-hand-color-selection"
  _"_Hand Color"
  "Color Part of the Image"
  "A.J. Bobo"
  "copyright 2008"
  "October 20, 2008"
  "RGB*"
  SF-IMAGE		"Input Image"	0
  SF-DRAWABLE	"Input Drawable"	0
  SF-VALUE		"Feather Amount"	"5"
  SF-OPTION		"Desaturate Mode"	'("Lightness" "Luminosity" "Average")
  SF-ADJUSTMENT	"Transparency"	'(255 0 255 1 16 0 SF-SLIDER)
)

(script-fu-menu-register "script-fu-ajbobo-hand-color-selection"
  _"<Image>/A.J.Bobo"
)