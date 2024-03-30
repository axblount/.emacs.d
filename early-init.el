;;;; Early init -*- lexical-binding: t; -*-

;; the "original" gc hack
(defmacro time-function (&rest body)
  (let ((time (gensym)))
    `(let ((,time (current-time)))
       ,@body
       (float-time (time-since ,time)))))

(defvar k-gc-timer
  (run-with-idle-timer 15 t
		       (lambda ()
			   (message "Garbage collector has run for %.06fsec"
				    (time-function (garbage-collect)))))
  "A timer that will garbage collect whenever Emacs is idle for 15 seconds.")

(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold #x40000000)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t
      frame-inhibit-implied-resize t
      window-resize-pixelwise t
      frame-resize-pixelwise t)

(setq package-enable-at-startup nil)

(add-to-list 'default-frame-alist
	     '(font . "DejaVu Sans Mono-14"))

;; Avoid the bright white square while loading.
;; (add-to-list 'default-frame-alist
;; 	     '(background-color . "#000000"))
