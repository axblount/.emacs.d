;;;; Alex Blount's init.el -*- lexical-binding: t; -*-
;; 2023-08-25

;;; utf-8, everywhere, all the time
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")

;; no file of mine will have trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(set-frame-font "DejaVu Sans Mono 14" nil t)

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
(setq custom-file (make-temp-file "emacs-custom"))

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

(electric-pair-mode 1) ; Insert closing )]}
(transient-mark-mode 1) ; Modern text selection style
(save-place-mode 1) ; Save last position in file
(savehist-mode 1) ; Save command history

;; autocomplete on tab
(setq tab-always-indent 'complete)
(add-to-list 'completion-styles 'initials t)

(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

;; Used to override :q in evil mode
(defun write-and-quit-current-buffer ()
  "This is used to emulate :wq"
  (interactive)
  (save-buffer)
  (kill-current-buffer))

;;
;; Packaging
;;
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
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

(use-package hyperbole
  :config
  (hyperbole-mode))

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
;; Aesthetics
;;
;;(load-theme 'leuven t)
(use-package solarized-theme
  :config
  (load-theme 'solarized-light t))
