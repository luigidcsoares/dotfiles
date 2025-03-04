(eval-when-compile (require 'use-package))

(use-package activities
  :ensure t
  :hook (after-init . activities-mode)
  :bind
  (("C-c a n" . activities-new)
   ("C-c a d" . activities-define)
   ("C-c a a" . activities-resume)
   ("C-c a s" . activities-suspend)
   ("C-c a k" . activities-kill)
   ("C-c a RET" . activities-switch)
   ("C-c a b" . activities-switch-buffer)
   ("C-c a g" . activities-revert)
   ("C-c a l" . activities-list)))

(use-package activities-tabs :hook (after-init . activities-tabs-mode))
(use-package activities-list)

(use-package consult-with-activities
  :no-require t
  :after (activities activities-tabs consult)
  :config
  ;; Type `a` to show only buffers related to current activity, if any:
  (defun my/activities-local-buffer-p (buffer)
    "Returns non-nil if BUFFER is present in `activities-current'."
    (when (activities-current)
      (memq buffer (activities-tabs--tab-parameter
		    'activities-buffer-list
		    (activities-tabs--tab (activities-current))))))

  (defvar my/consult--source-activities-buffer
    `(:name "Activities Buffers"
            :narrow   ?a
            :category buffer
            :face     consult-buffer
            :history  buffer-name-history
            :state    ,#'consult--buffer-state
            :items ,(lambda () (consult--buffer-query
				:predicate #'my/activities-local-buffer-p
				:sort 'visibility
				:as #'buffer-name)))
    "Activities local buffers candidate source for `consult-buffer'.")
  
  (add-to-list 'consult-buffer-sources 'my/consult--source-activities-buffer))

(use-package display-line-numbers
  :hook ((prog-mode text-mode conf-mode) . display-line-numbers-mode))

;; TODO: Configure dashboard package
;; Temporarily disable splash screen
(setq inhibit-startup-message t)

(use-package catppuccin-theme
  :ensure t
  :custom (catppuccin-enlarge-headings nil)
  :config (load-theme 'catppuccin :no-confirm))

(set-face-attribute 'default nil :font "Iosevka Nerd Font Mono" :height 150)
(set-face-attribute 'variable-pitch nil :font "Iosevka Etoile" :height 150)

(use-package ligature
  :ensure t
  :config
  ;; Enable all Iosevka ligatures in programming modes
  (ligature-set-ligatures
   'prog-mode
   '("<---" "<--"  "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->"
     "<---->" "<!--" "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">="
     "<=>" "<==>" "<===>" "<====>" "<!---" "<~~" "<~" "~>" "~~>" "::"
     ":::" "==" "!=" "===" "!==" ":=" ":-" ":+" "<*" "<*>" "*>" "<|"
     "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))
  ;; Enables ligature checks globally in all buffers.
  ;; You can also do it per mode with `ligature-mode'.
  (global-ligature-mode t))

(use-package nerd-icons :ensure t)
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :custom (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(defun my/meow-qwerty ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . "H-j")
   '("k" . "H-k")
   '("[" . "H-[")
   '("]" . "H-]")
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :ensure t
  :demand t
  :config
  (my/meow-qwerty)
  (meow-leader-define-key '("u" . meow-universal-argument))
  (meow-global-mode))

(use-package autorevert :config (global-auto-revert-mode))

(use-package files
  :custom
  ((create-lockfiles nil)
   (make-backup-files nil)
   (auto-save-default t)))

(use-package org
  :hook (org-mode . visual-line-mode)
  :custom
  (org-hide-emphasis-markers t)
  (org-startup-indented t)
  (org-pretty-entities t)
  (org-src-preserve-indentation nil)
  (org-edit-src-content-indentation 0))

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

(defun my/org-babel-do-load-languages ()
  (org-babel-do-load-languages 'org-babel-load-languages
			       org-babel-load-languages))

(use-package ob
  :hook (after-init . my/org-babel-do-load-languages)
  :custom
  ;; Don't need permission, just be careful!
  (org-confirm-babel-evaluate nil)
  (org-babel-load-languages
   '((C . t)
     (elixir . t)
     (emacs-lisp . t)
     (nix . t)
     (python . t)
     (shell . t))))

(use-package ob-elixir :ensure t :defer t)
(use-package ob-nix :ensure t :defer t)

(use-package tex
  :ensure auctex
  :custom
  (TeX-parse-self t)
  (TeX-auto-save t)
  (TeX-electric-sub-and-superscript t)
  ;; Use hidden directories for AUCTeX files.
  (TeX-auto-local ".auctex-auto")
  (TeX-style-local ".auctex-style")
  ;; Just save, don't ask before each compilation.
  (TeX-save-query nil)
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-method 'synctex)
  ;; Don't start the Emacs server when correlating sources.
  (TeX-source-correlate-start-server nil)
  :config
  (add-to-list 'TeX-view-program-selection '(output-pdf "PDF Tools"))
  (add-hook 'TeX-mode-hook #'visual-line-mode)
  (add-hook 'TeX-after-compilation-finished-functions
	    #'TeX-revert-document-buffer))

(use-package nix-mode :ensure t :mode "\\.nix\\'")

(use-package cc-mode
  :mode ("\\.tpp\\'" . c++-mode)
  :config (c-set-offset 'innamespace 0))

(use-package elixir-mode
  :ensure t
  :mode ("\\.ex\\'" "\\.exs\\'"))

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")

(use-package rustic
  :ensure t
  :config
  (setq rustic-format-on-save nil)
  :custom
  (rustic-cargo-use-last-stored-arguments t)
  (rustic-lsp-client 'eglot))

(when (and (getenv "WAYLAND_DISPLAY")
	   (not (equal (getenv "GDK_BACKEND") "x11")))
  (setq interprogram-cut-function
	(lambda (text)
	  (start-process "wl-copy" nil "wl-copy" "--trim-newline"
			 "--type" "text/plain;charset=utf-8" text))))

(use-package envrc
  :ensure t
  :if (executable-find "direnv")
  :hook ((after-init . envrc-global-mode)))

(use-package pdf-tools
  :ensure t
  :mode (("\\.pdf\\'" . pdf-view-mode))
  :config
  (use-package pdf-occur :commands (pdf-occur-global-minor-mode))
  (use-package pdf-history :commands (pdf-history-minor-mode))
  (use-package pdf-links :commands (pdf-links-minor-mode))
  (use-package pdf-outline :commands (pdf-outline-minor-mode))
  (use-package pdf-annot :commands (pdf-annot-minor-mode))
  (use-package pdf-sync :commands (pdf-sync-minor-mode))
  (pdf-tools-install))

(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package consult
  :ensure t
  :bind
  (([remap switch-to-buffer] . consult-buffer)
   ;; C-s bindings (search map)
   ("C-c s f" . consult-find)
   ("C-c s l" . consult-line)
   ("C-c s L" . consult-line-multi)
   ("C-c s r" . consult-ripgrep)))

(use-package embark
  :ensure t
  :bind
  (("C-c e a" . embark-act)
   ("C-c e d" . embark-dwim))
  :custom
  (embark-indicators '(embark-minimal-indicator
                       embark-highlight-indicator
                       embark-isearch-highlight-indicator))
  (embark-prompter #'embark-completing-read-prompter)
  :init (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package eat
  :ensure t
  :bind ("C-c t" . eat))

(setq shell-command-switch "-ic")
