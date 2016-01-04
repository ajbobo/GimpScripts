; Resizer script.
; Takes an image and resizes it and saves it with a similar name
; If the file is going to be saved in a different directory, that directory must already exist

; This function was defined in SIOD (used in GIMP 2.2) but not in TinyScheme (used in GIMP 2.4)
(define (string-search target searchstr)
  (let* ((ptr 0)
         (res -1)
         (len (string-length searchstr))
        )
        (while (and
                   (< ptr len)
                   (not (char=? (string-ref searchstr ptr) target))
               )
               (set! ptr (+ ptr 1))
               ;(gimp-message (string-append "ptr = " (number->string ptr) " = " (string (string-ref searchstr ptr))))
        )
        ;(gimp-message (string-append "endptr = " (number->string ptr)))
        (if (< ptr len)
            (set! res ptr)
            (set! res -1)
        )
        res
  )
)

(define (script-fu-ajbobo-resizer img drawable finalsize close directory newtext)
  ; Start the undo group - save context settings
  (gimp-image-undo-group-start img)
  (gimp-context-push)

  ; Resize the image
  (gimp-image-scale img finalsize finalsize)

  ; Save the file under a new name (path\filename.bmp -> path\directory\filenamenewtext.bmp)
  ; Removes each token from the left up to a \ and adds it to buildpath. When the last token is found (the file name), the new directory name is inserted
  (let* ((fullpath (car (gimp-image-get-filename img)))
         (pathlen (- (string-length fullpath) 4))
         (extension (substring fullpath pathlen (string-length fullpath)))
         (partialpath (substring fullpath 0 pathlen))
         (buildpath "")
         (longname "")
         (slashloc -1)
        )
        (set! slashloc (string-search #\\ partialpath))
        (while (not (= -1 slashloc)) ; Sets slashloc to the position of a \ and then makes sure it found it
               (set! buildpath (string-append buildpath (substring partialpath 0 (+ 1 slashloc))))
               ;(gimp-message (string-append "buildpath: " buildpath))
               (set! partialpath (substring partialpath (+ 1 slashloc) (string-length partialpath)))
               ;(gimp-message (string-append "partialpath: " partialpath))
               (set! slashloc (string-search #\\ partialpath))
        )
        ; This adds the directory to the path and newtext to the file name
        (if (> (string-length directory) 0)
            (set! longname (string-append buildpath directory "\\" partialpath newtext extension))
            (set! longname (string-append buildpath partialpath newtext extension))
        )
        ;(gimp-message (string-append "longname: " longname))

        ; Save the file
        (gimp-image-set-filename img longname)
        (gimp-file-save 0 img drawable longname longname)
  )

  ; Restore previous settings and end the undo group
  (gimp-selection-none img)
  (gimp-context-pop)
  (gimp-image-undo-group-end img)

  ; Mark the image as not changed - so it can be closed immediately
  (gimp-image-clean-all img)

  ; Close the image if the user wants
  (if (= close TRUE)
      (gimp-display-delete img)
  )

  ; Update the image
  (gimp-displays-flush)
)

(script-fu-register "script-fu-ajbobo-resizer"
  _"_Resizer"
  "Resizer"
  "A.J. Bobo"
  "copyright 2007"
  "October 26, 2007"
  ""
  SF-IMAGE	"Input Image"		0
  SF-DRAWABLE	"Input Drawable"	0
  SF-VALUE	"Final Size"		"20"
  SF-TOGGLE	"Close after saving"	FALSE
  SF-TEXT	"Directory"		""
  SF-TEXT	"New Text"		"small"
)

(script-fu-menu-register "script-fu-ajbobo-resizer"
  _"<Image>/A.J.Bobo"
)