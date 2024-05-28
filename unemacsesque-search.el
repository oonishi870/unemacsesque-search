;; minibufferを終了せずに文字列を取得する
(defun unemacslike-search--minibuffer-string()
;;  (interactive)
  (with-current-buffer (window-buffer (active-minibuffer-window))
	(buffer-substring-no-properties (+ (length (minibuffer-prompt)) 1) (point-max))))
;;(provide 'unemacslike-search--minibuffer-string)

(defun unemacslike-search--highlight-match-string (input)
  "Highlight matching INPUT in the parent buffer."
  (remove-overlays nil nil 'unemacslike-search--highlight t)
  (when (> (length input) 0)
    (save-excursion
      (goto-char (point-min))
      (while (search-forward input nil t)
        (let ((ov (make-overlay (match-beginning 0) (match-end 0))))
          (overlay-put ov 'face 'highlight)
          (overlay-put ov 'unemacslike-search--highlight t)
          (overlay-put ov 'priority 5)
)))))


(defun unemacslike-search--highlight-on-live ()
  (interactive)
  (with-current-buffer (window-buffer (minibuffer-selected-window)) 
    (unemacslike-search--highlight-match-string (unemacslike-search--minibuffer-string)))
)


(define-minor-mode unemacslike-search-mode
  ""
  :init-value nil
  :global nil                                     ;デフォルトで無効にする
  :lighter ""                                    ;モードラインに表示しない
  :keymap '()
  (if unemacslike-search-mode
      (progn
        (add-hook 'post-command-hook #'unemacslike-search--highlight-on-live)
      )
      (progn
        (remove-hook 'post-command-hook #'unemacslike-search--highlight-on-live)
        (remove-highlight)
      )
  )
)

(defun remove-highlight()
  (with-current-buffer (window-buffer (minibuffer-selected-window)) 
    (remove-overlays nil nil 'unemacslike-search--highlight t)
    (remove-overlays nil nil 'my-dynamic-highlight t)))




(defun unemacslike-search--begin-hook()
  (interactive)
  (unemacslike-search-mode 1)
)
(defun unemacslike-search--exit-hook()
  (interactive)
  (unemacslike-search-mode 0)
)


(defun unemacslike-search ()
  "Use the minibuffer with `my-minibuffer-mode`."
  (interactive)
  (add-hook 'minibuffer-setup-hook 'unemacslike-search--begin-hook)
  (add-hook 'minibuffer-exit-hook  'unemacslike-search--exit-hook)

  (unwind-protect
    (read-string "Enter your input: ")
    (remove-hook 'minibuffer-setup-hook 'unemacslike-search--begin-hook)
    (remove-hook 'minibuffer-exit-hook  'unemacslike-search--exit-hook)
))



(defun unemacslike-search--forward-search ()
  "Search forward using the minibuffer input and highlight matches."
  (let ((input (unemacslike-search--minibuffer-string)))
    (when (> (length input) 0)
      (search-forward input nil t)
      (unemacslike-search-dynamic-highlight input)
      (recenter))))

(defun unemacslike-search-forward-search ()
  (interactive)
  (with-current-buffer (window-buffer (minibuffer-selected-window))
    (remove-hook 'minibuffer-begin-hook  'unemacslike-search--begin-hook)
    (remove-hook 'minibuffer-exit-hook  'unemacslike-search--exit-hook)
    (select-window (minibuffer-selected-window) )
    (unemacslike-search--forward-search)
    (select-window (minibuffer-window))
    (add-hook 'minibuffer-begin-hook  'unemacslike-search--begin-hook)
    (add-hook 'minibuffer-exit-hook  'unemacslike-search--exit-hook)
  ))



(defun unemacslike-search--backward-search ()
  "Search backward using the minibuffer input and highlight matches."
  (let ((input (unemacslike-search--minibuffer-string)))
    (when (> (length input) 0)
      (search-backward input nil t)
      (unemacslike-search-dynamic-highlight input))))

(defun unemacslike-search-backward-search ()
  (interactive)
  (print "backward2")
  (with-current-buffer (window-buffer (minibuffer-selected-window))
    (remove-hook 'minibuffer-begin-hook  'unemacslike-search--begin-hook)
    (remove-hook 'minibuffer-exit-hook  'unemacslike-search--exit-hook)
    (select-window (minibuffer-selected-window) )
    (unemacslike-search--backward-search)
    (select-window (minibuffer-window))
    (add-hook 'minibuffer-begin-hook  'unemacslike-search--begin-hook)
    (add-hook 'minibuffer-exit-hook  'unemacslike-search--exit-hook)
  
))


(defun unemacslike-search-dynamic-highlight (input)
  "Highlight matching INPUT in the current buffer."
  (remove-overlays nil nil 'my-dynamic-highlight t)
  (save-excursion
    ;;(goto-char (point-min))
    (search-forward input nil t)
    (let ((ov (make-overlay (match-beginning 0) (match-end 0))))
      (overlay-put ov 'face 'isearch)
      (overlay-put ov 'my-dynamic-highlight t)
      (overlay-put ov 'priority 200))))







(bind-keys :map unemacslike-search-mode-map
  ("C-r" . unemacslike-search-backward-search)
  ("C-f" . unemacslike-search-forward-search)
  ("RET" . exit-minibuffer)
  ("C-g" . minibuffer-keyboard-quit)
)

(bind-keys :map unemacslike-search-mode-map
  ("RET" . unemacslike-search-forward-search)
  ("<S-return>" . unemacslike-search-backward-search)
  ("C-g" . exit-minibuffer)
)
