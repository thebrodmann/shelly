(load "~steshaw/External/Projects/rust-mode/rust-mode.el")

(viper-mode)

(when (featurep 'aquamacs)
    ;; switch to white on black
    (color-theme-initialize)
    (color-theme-clarity)
    ;; switch to Garamond 36pt
;;    (aquamacs-autoface-mode 0)
;;    (set-frame-font "-apple-garamond-medium-r-normal--36-360-72-72-m-360-iso10646-1")
    ;; switch to fullscreen mode
;;    (aquamacs-toggle-full-frame))
)
