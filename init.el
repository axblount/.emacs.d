;;;; Alex Blount's init.el -*- lexical-binding: t; -*-
;; 2023-08-25

;;; utf-8, everywhere, all the time
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")

(setq warning-minimum-level :error)

;; no file of mine will have trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; nicer visual bell
(setq is-mode-line-flashing nil)
(defun flash-mode-line ()
  (unless is-mode-line-flashing
    (setq is-mode-line-flashing t)
    (invert-face 'mode-line)
    (run-with-timer 0.1 nil #'invert-face 'mode-line)
    (run-with-timer 0.2 nil #'invert-face 'mode-line)
    (run-with-timer 0.3 nil (lambda ()
			      (invert-face 'mode-line)
			      (setq is-mode-line-flashing nil)))))
(setq ring-bell-function 'flash-mode-line)

;; backups
(setq backup-directory-alist
      `(("." . ,(locate-user-emacs-file "backup/")))
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2)

;; no lockfiles
(setq create-lockfiles nil)

;; customize ephemeral
(setq custom-file (locate-user-emacs-file "custom.el"))

(setq indent-tabs-mode nil)

(defun show-me-some-spaces ()
  "Setup showing whitespace, used in hooks"
  (setq show-trailing-whitespace t
        indicate-empty-lines t
        indicate-buffer-boundaries t))
(add-hook 'text-mode-hook #'show-me-some-spaces)
(add-hook 'prog-mode-hook #'show-me-some-spaces)

(setq show-paren-delay 0.125)
(setq show-paren-style 'expression) ; highlight entire expression
(show-paren-mode 1)

(global-hl-line-mode 1)
(electric-pair-mode 1) ; Insert closing )]}
(transient-mark-mode 1) ; Modern text selection style
(save-place-mode 1) ; Save last position in file
(savehist-mode 1) ; Save command history

;; autocomplete on tab
(setq tab-always-indent 'complete)
(add-to-list 'completion-styles 'initials t)

;; soft wrap
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

;; don't ask to kill buffers with attached processes
(setq kill-buffer-query-functions
      (remq 'process-kill-buffer-query-function
	    kill-buffer-query-functions))


;; Used to override :q in evil mode
(defun write-and-quit-current-buffer ()
  "This is used to emulate :wq"
  (interactive)
  (save-buffer)
  (kill-current-buffer))

;;
;; Packaging
;;
(add-to-list 'load-path
	     (locate-user-emacs-file "lisp/"))
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;;
;; Functional
;;
(use-package slime
  :init
  (setq inferior-lisp-program "sbcl"))

(use-package project)

(use-package org
  :init
  (add-hook 'org-mode-hook 'auto-fill-mode)
  (setq org-startup-indented t
        org-fontify-whole-heading-line t
        org-agenda-files '("~/notes/")))

(use-package geiser-guile
  :after evil-collection
  :config
  (evil-collection-geiser-setup))

;;
;; Editing the Evil Way
;;
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-undo-system 'undo-fu
        evil-respect-visual-line-mode t)
  :config
  ;; prevent :wq and :q from exitting emacs
  ;; use :wqall or :qall to exit.
  ;; Also, fat fingersss
  (evil-ex-define-cmd "q[uit]" 'kill-current-buffer)
  (evil-ex-define-cmd "Q[uit]" 'kill-current-buffer)
  (evil-ex-define-cmd "wq" 'write-and-quit-current-buffer)
  (evil-ex-define-cmd "Wq" 'write-and-quit-current-buffer)
  (evil-ex-define-cmd "WQ" 'write-and-quit-current-buffer)
  (evil-ex-define-cmd "W[rite]" 'evil-write)
  ;; Punch it!
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package undo-fu)

;; Autocomplete niceness
(use-package corfu
  :config
  (global-corfu-mode))

;; A little nicer M-x view
(use-package vertico
  :config
  (vertico-mode))

;;
;; Git
;;
(use-package magit
  :after evil
  :config
  (evil-ex-define-cmd "git" #'magit-status))

;;
;; Accounting
;;
;; (use-package ledger-mode
;;   :init
;;   (setq ledger-highlight-xact-under-point nil))

;;
;; Aesthetics
;;
;; (use-package moe-theme
;;   :config
;;   (setq moe-theme-modeline-color 'purple)
;;   (moe-light))
;; (use-package modus-themes
;;   :init
;;   (setq modus-themes-italic-constructs t
;; 	modus-themes-bold-constructs t)
;;   :config
;;   (load-theme 'modus-operandi-tinted :no-confirm))

;;
;; Filetypes
;;
(when (version< emacs-version "29")
  (use-package eglot))

;;
;; The End
;;

(defun random-choice (list)
  (nth (random (length list)) list))

(defvar barf-pejorative
  (random-choice
   '(loser
     jerk
     asshole
     fucker
     dipshit
     knucklehead
     babygirl
     babyboy
     sucker
     goofball
     ding-dong
     bestie)))

(setq initial-scratch-message
      (format "\
;; Emacs started on %s
;; %d packages loaded in %s seconds
;; Welcome to emacs %s, %s
"
	      (format-time-string "%A %B %-d at %H:%M:%S" (current-time))
	      (length package-alist)
	      (emacs-init-time)
	      emacs-version
	      barf-pejorative))
