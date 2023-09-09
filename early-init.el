;;;; Early init

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t
      initial-scratch-message ";;;; what up\n"
      window-resize-pixelwise t
      frame-resize-pixelwise t)

(setq package-enable-at-startup nil)
