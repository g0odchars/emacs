(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(define-key global-map (kbd "C-x k") #'kill-this-buffer)
(define-key global-map (kbd "C-x K") #'kill-buffer-and-window)
(define-key global-map (kbd "M-u") #'undo)
(define-key global-map (kbd "M-[") #'previous-buffer)
(define-key global-map (kbd "M-]") #'next-buffer)
(define-key global-map (kbd "C-M-k") #'kill-whole-line)
(define-key global-map (kbd "M-O") #'previous-window-any-frame)
(define-key global-map (kbd "C-x 2") #'(lambda ()
			      (interactive)
			      (split-window-below)
			      (other-window 1)))
(define-key global-map (kbd "C-x 3") #'(lambda ()
	   (interactive)
	   (split-window-right)
	   (other-window 1)))
(define-key global-map (kbd "C-x F") 'find-file-at-point)

(setq frame-resize-pixelwise t)
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(delete-selection-mode t)
(global-auto-revert-mode t)
(electric-pair-mode 1)

;; (set-face-attribute 'default nil :font "Fira Code-11")
;; (set-face-attribute 'default nil :background "#111")
;; (set-face-attribute 'default nil :foreground "#FFF")
;; (set-face-attribute 'fringe nil :background "#111")
;; (set-face-attribute 'mode-line nil :box nil)
;; (set-face-attribute 'mode-line nil :background "#333")
;; (set-face-attribute 'mode-line nil :foreground "#fff")
;; (set-face-attribute 'mode-line-inactive nil :box nil)
;; (set-face-attribute 'mode-line-inactive nil :background "#222")
;; (set-face-attribute 'mode-line-inactive nil :foreground "#444")
;; (set-face-attribute 'line-number-current-line nil :foreground "#fff")

(load-theme 'modus-vivendi t)

(setq backup-directory-alist (list (cons ".*" (expand-file-name "~/.ebackup"))))
(fset 'yes-or-no-p 'y-or-n-p)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq show-trailing-whitespace t)
(setq show-paren-delay 0)
(setq large-file-warning-threshold nil)
(setq-default create-lockfiles nil)

(defun other-window-reverse (&optional x)
	(interactive "P")
	(if (equal x nil)
	    (other-window -1)
	  (other-window (- 0 x))))
(define-key global-map (kbd "M-S-o") #'other-window-reverse)

(defun rename1 (new-name)
	"Renames both current buffer and file it's visiting to NEW-NAME."
	(interactive (list (completing-read "New name: " nil nil nil (buffer-name))))
	(let ((name (buffer-name))
	      (filename (buffer-file-name)))
	  (if (not filename)
	      (message "Buffer '%s' is not visiting a file!" name)
	    (if (get-buffer new-name)
		(message "A buffer named '%s' already exists!" new-name)
	      (progn
		(rename-file name new-name 1)
		(rename-buffer new-name)
		(set-visited-file-name new-name)
		(set-buffer-modified-p nil))))))

(defun move1 (dir)
	"Moves both current buffer and file it's visiting to DIR."
	(interactive "DNew directory: ")
	(let* ((name (buffer-name))
	       (filename (buffer-file-name))
	       (dir
		(if (string-match dir "\\(?:/\\|\\\\)$")
		    (substring dir 0 -1) dir))
	       (newname (concat dir "/" name)))

	  (if (not filename)
	      (message "Buffer '%s' is not visiting a file!" name)
	    (progn (copy-file filename newname 1)
		   (delete-file filename)
		   (set-visited-file-name newname)
		   (set-buffer-modified-p nil)
		   t))))

(defun save-jump-cursor ()
  "Save the cursor position to register 1 or jump to it if it is set"
  (interactive)
  (if (eq (cdr (assoc 1 register-alist)) 0)
      (point-to-register 1)
    (progn
	(register-to-point 1)
	(setf (cdr (assoc 1 register-alist)) 0))))
(define-key global-map (kbd "C-q") #'save-jump-cursor)

(setq search-whitespace-regexp ".*")
(setq search-lax-whitespace t)
(setq isearch-regexp-lax-whitespace nil)

(add-to-list 'display-buffer-alist
             '("^\\*shell\\*$" . (display-buffer-same-window)))



(use-package eglot
  :ensure t
  :config

  (use-package magit
    :ensure t
    :config
    (define-key global-map (kbd "C-x g") 'magit))

  (use-package company
    :ensure t
    :config
    (setq company-idle-delay 0)
    (global-company-mode))

  (add-hook 'python-mode-hook 'eglot-ensure)
  (add-hook 'c++-mode-hook 'eglot-ensure)
  (add-hook 'go-mode-hook 'eglot-ensure)
  (defun eglot-set-eldoc-functions ()
    (setq-local eldoc-documentation-functions '(flymake-eldoc-function
						eglot-signature-eldoc-function
						eglot-hover-eldoc-function)))
  (add-hook 'eglot-managed-mode-hook #'eglot-set-eldoc-functions)
  (setq-default indent-tabs-mode nil))



(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))


(defalias 'ev-r #'eval-region)
(with-eval-after-load 'flycheck
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

(use-package neotree
  :ensure t
  :config
  (use-package all-the-icons
    :ensure t)
  (setq neo-autorefresh t))


(defmacro csetq (variable value)
  `(funcall (or (get ',variable 'custom-set)
                'set-default)
            ',variable ,value))

(csetq ediff-window-setup-function 'ediff-setup-windows-plain)
(csetq ediff-split-window-function 'split-window-horizontally)
(csetq ediff-diff-options "-w")
(winner-mode)
(add-hook 'ediff-after-quit-hook-internal 'winner-undo)
