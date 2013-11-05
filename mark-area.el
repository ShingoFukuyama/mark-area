;;; mark-area.el --- Mark two points and provide these position to ather elisp -*- coding: utf-8; lexical-binding: t -*-

;; Copyright (C) 2013 by Shingo Fukuyama

;; Version: 1.0
;; Author: Shingo Fukuyama - http://fukuyama.co
;; URL: https://github.com/ShingoFukuyama/mark-area
;; Created: Oct 29 2013
;; Keywords: mark point area
;; Package-Requires: ((emacs "24"))

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;;; Commentary:

;; (require 'mark-area)
;; (setq mark-area-beginning-char "☆") ;; Beginning mark
;; (setq mark-area-end-char "★")       ;; End mark
;; (global-set-key (kbd "M-M") 'mark-area-at-point) ;;[shift+meta+m]

;; This programs' mark has no entity but visible.
;; You can delete marks with DEL key.
;; And when two marks exist, `mark-area-at-point' delete those marks.

;; Apply follow three functions to other elisp you want to use.
;; (mark-area-set-local-variable)
;; (mark-area-b) ;; mark begging point
;; (mark-area-e) ;; mark end point
;;
;; Example
;; [syohex/emacs-quickrun] https://github.com/syohex/emacs-quickrun

;; (require 'quickrun)
;; (defun quickrun-mark-area-ad-hoc ()
;;   (interactive)
;;   (mark-area-set-local-variable)
;;   (cond
;;    ;; C-u M-x quickrun-ad-hoc with region
;;    ((and mark-active current-prefix-arg)
;;     (deactivate-mark)
;;     (quickrun-replace-region (region-beginning) (region-end)))
;;    ;; M-x quickrun-ad-hoc with region
;;    (mark-active
;;     (deactivate-mark)
;;     (quickrun :start (region-beginning) :end (region-end)))
;;    ;; M-x quickrun-ad-hoc with specified area
;;    ((and (mark-area-b) (mark-area-e))
;;     (quickrun :start (mark-area-b)
;;               :end (mark-area-e)))
;;    (t (quickrun))))

;;; Code:

(eval-when-compile (require 'cl))

(defvar mark-area-beginning-char "☆")
(defvar mark-area-end-char "★")

(defvar mark-area-beg-overlay)
(defvar mark-area-end-overlay)
(defvar mark-area-first-time)

(defun mark-area-set-local-variable ()
  (unless (boundp 'mark-area-first-time)
    (set (make-local-variable 'mark-area-beg-overlay)
         (make-overlay (point) (point)))
    (set (make-local-variable 'mark-area-end-overlay)
         (make-overlay (point) (point)))
    (delete-overlay mark-area-beg-overlay)
    (delete-overlay mark-area-end-overlay)
    (set (make-local-variable 'mark-area-first-time) nil)))

(defadvice delete-char (around ad-my-delete-mark activate)
  "Delete mark when cursor at the next of mark.
Work as buffer local function."
  (if (not (and (boundp 'mark-area-beg-overlay) mark-area-beg-overlay))
      ad-do-it
    (cond ((eq (point) (mark-area-b))
           (delete-overlay mark-area-beg-overlay))
          ((eq (point) (mark-area-e))
           (delete-overlay mark-area-end-overlay))
          (t ad-do-it))))

;;;###autoload
(defun mark-area-at-point ()
  (interactive)
  "Set beginning mark or end mark according to the situation.
If both exist, delete those mark."
  (mark-area-set-local-variable)
  (let (($p (point))
        ($beg (mark-area-b))
        ($end (mark-area-e)))
    (cond
     ((and $beg $end)
      (mark-area-clear))
     ;; Not found beginning mark
     ((not $beg)
      (setq mark-area-beg-overlay (make-overlay $p $p))
      (overlay-put mark-area-beg-overlay 'after-string
                   (propertize mark-area-beginning-char
                               'face 'font-lock-function-name-face))
      ;; Swap if the new beginning mark is after the end mark
      (when (and $end (> $p $end))
        (move-overlay mark-area-beg-overlay $end $end)
        (move-overlay mark-area-end-overlay $p $p)))
     ;; Not found end mark
     ((and (not $end)
           (not (eq $p $beg)))
      (setq mark-area-end-overlay (make-overlay $p $p))
      (overlay-put mark-area-end-overlay 'after-string
                   (propertize mark-area-end-char
                               'face 'font-lock-function-name-face))
      ;; Swap if the new end mark is before the beginning mark
      (when (and $beg (< $p $beg))
        (move-overlay mark-area-beg-overlay $p $p)
        (move-overlay mark-area-end-overlay $beg $beg))))))

(defun mark-area-clear ()
  (interactive)
  (delete-overlay mark-area-beg-overlay)
  (delete-overlay mark-area-end-overlay))

(defun mark-area-goto-beginning ()
  (interactive)
  (let (($p (mark-area-b)))
    (if $p
        (goto-char $p)
      (message "Beginning mark not found"))))

(defun mark-area-goto-end ()
  (interactive)
  (let (($p (mark-area-e)))
    (if $p
        (goto-char $p)
      (message "End mark not found"))))

(defun mark-area-b () (interactive)
  (overlay-start mark-area-beg-overlay))
(defun mark-area-e () (interactive)
  (overlay-start mark-area-end-overlay))
(defun mark-area-cons () (interactive)
  (cons (mark-area-b) (mark-area-e)))


(provide 'mark-area)
;;; mark-area.el ends here
