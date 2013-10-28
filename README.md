Mark two points and provide these position to ather elisp.
This programs' mark has no entity but visible.
You can delete marks with DEL key.
And when two marks exist, `mark-area-at-point` delete those marks. 

[20 seconds Youtube live coding](http://www.youtube.com/embed/OGXHUBiwy14?rel=0)

### Setting

```el
(require 'mark-area)
(setq mark-area-beginning-char "☆") ;; Beginning mark
(setq mark-area-end-char "★")       ;; End mark
(global-set-key (kbd "M-M") 'mark-area-at-point) ;;[shift+meta+m]
```

### For example

Apply mark-area.el to quickrun.el like below. 

```el
(require 'quickrun) ;; https://github.com/syohex/emacs-quickrun
(defun quickrun-mark-area-ad-hoc ()
  (interactive)
  (mark-area-set-local-variable)
  (cond
   ;; C-u M-x quickrun-ad-hoc with region
   ((and mark-active current-prefix-arg)
    (deactivate-mark)
    (quickrun-replace-region (region-beginning) (region-end)))
   ;; M-x quickrun-ad-hoc with region
   (mark-active
    (deactivate-mark)
    (quickrun :start (region-beginning) :end (region-end)))
   ;; M-x quickrun-ad-hoc with specified area
   ((and (overlay-start mark-area-beg-overlay)
         (overlay-start mark-area-end-overlay))
    (quickrun :start (overlay-start mark-area-beg-overlay)
              :end (overlay-start mark-area-end-overlay)))
   (t (quickrun))))
```
