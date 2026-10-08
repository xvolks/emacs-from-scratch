;; init-mac-and-linux.el — Multi-platform Emacs configuration  -*- lexical-binding: t; -*-
;; Derived from init.el, adapted for macOS and Linux (x86_64 & aarch64)
;; -*- lexical-binding: t; -*-

(elisp-enable-lexical-binding t)
;; Log native compilation warnings silently instead of popping up a buffer
(setq native-comp-async-report-warnings-errors 'silent)

;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 180)
(defvar efs/default-variable-font-size 180)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(99 . 99))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                         ("org"    . "https://orgmode.org/elpa/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("elpa"   . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package general
  :demand t
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(use-package drag-stuff)
;; https://github.com/kaushalmodi/.emacs.d/blob/master/setup-files/setup-drag-stuff.el
;; http://emacs.stackexchange.com/a/13942/115
(defvar modi/drag-stuff--point-adjusted nil)
(defvar modi/drag-stuff--point-mark-exchanged nil)

(defun modi/drag-stuff--adj-pt-pre-drag ()
  "If a region is selected AND the `point' is in the first column, move
back the point by one char so that it ends up on the previous line. If the
point is above the mark, exchange the point and mark temporarily."
  (when (region-active-p)
    (when (< (point) (mark)) ; selection is done starting from bottom to up
      (exchange-point-and-mark)
      (setq modi/drag-stuff--point-mark-exchanged t))
    (if (zerop (current-column))
        (progn
          (backward-char 1)
          (setq modi/drag-stuff--point-adjusted t))
      ;; If point did not end up being on the first column after the
      ;; point/mark exchange, revert that exchange.
      (when modi/drag-stuff--point-mark-exchanged
        (exchange-point-and-mark) ; restore the original point and mark loc
        (setq modi/drag-stuff--point-mark-exchanged nil)))))

(defun modi/drag-stuff--rst-pt-post-drag ()
  "Restore the `point' to where it was by forwarding it by one char after
the vertical drag is done."
  (when modi/drag-stuff--point-adjusted
    (forward-char 1)
    (setq modi/drag-stuff--point-adjusted nil))
  (when modi/drag-stuff--point-mark-exchanged
    (exchange-point-and-mark) ; restore the original point and mark loc
    (setq modi/drag-stuff--point-mark-exchanged nil)))

(add-hook 'drag-stuff-before-drag-hook #'modi/drag-stuff--adj-pt-pre-drag)
(add-hook 'drag-stuff-after-drag-hook  #'modi/drag-stuff--rst-pt-post-drag)

(global-set-key (kbd "M-<up>")   #'drag-stuff-up)
(global-set-key (kbd "M-<down>") #'drag-stuff-down)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; ---- Platform-specific font configuration ----
;; macOS: "FiraCode Nerd Font Mono" (as installed via Homebrew)
;; Linux:  "FiraCode Font"    (as installed via apt/dnf/pacman)
(setq font-name
      (cond
       ((eq system-type 'darwin)
	;; macOS font names
	"FiraCode Nerd Font Mono")
       ((eq system-type 'gnu/linux)
	;; Linux font names — adjust if your distro uses different font naming
	"Fira Code")
       (t
	;; Fallback for other systems (Windows, etc.)
	"FiraCode Nerd Font")))

(setq font-name-variable
      (cond
       ((eq system-type 'darwin)
	;; macOS font names
	"Arial")
       ((eq system-type 'gnu/linux)
	;; Linux font names — adjust if your distro uses different font naming
	"Cantarell")
       (t
	;; Fallback for other systems (Windows, etc.)
	"Arial")))

(set-face-attribute 'default nil :font font-name :height efs/default-font-size)
(set-face-attribute 'fixed-pitch nil :font font-name :height efs/default-font-size)
(set-face-attribute 'variable-pitch nil :font font-name-variable :height efs/default-variable-font-size :weight 'regular)


(use-package nerd-icons
:ensure t
:config
  (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
    (nerd-icons-install-fonts t)))   
  :custom
  ;; Ensure this matches your installed font name exactly
  (nerd-icons-font-family "Symbols Nerd Font Mono"))
    
;; Nerd Font fallback — try both macOS and Linux font names
(let (font-name font-name))
  (when (member font-name (font-family-list))
    ;; Set the primary default font face
    (set-face-attribute 'default nil :family font-name :height 150)

    ;; Map Nerd Font specific unicode symbol blocks to the font fallback fontset
    (set-fontset-font t '(#xE000 . #xF8FF) (font-spec :family font-name))
    (set-fontset-font t '(#xF0000 . #xFFFFD) (font-spec :family font-name))))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "fde" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/Emacs.org")))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :init (load-theme 'doom-palenight t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(with-eval-after-load 'doom-modeline  ; Replace with your modeline package if not using Doom
  ;; Force specific Nerd Font icon blocks to be treated as single-column width
  (let ((row #xE000))
    (while (<= row #xF8FF)
      (aset char-width-table row 1)
      (setq row (1+ row))))

  (let ((row #xF0000))
    (while (<= row #xFFFFD)
      (aset char-width-table row 1)
      (setq row (1+ row)))))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(efs/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (let ((variable-font (cond
                        ((eq system-type 'darwin) "Arial")
                        ((eq system-type 'gnu/linux) "Cantarell")
                        (t "Arial"))))
    (dolist (face '((org-level-1 . 1.2)
                    (org-level-2 . 1.1)
                    (org-level-3 . 1.05)
                    (org-level-4 . 1.0)
                    (org-level-5 . 1.1)
                    (org-level-6 . 1.1)
                    (org-level-7 . 1.1)
                    (org-level-8 . 1.1)))
      (set-face-attribute (car face) nil :font variable-font :weight 'regular :height (cdr face))))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground 'unspecified :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org"
          "~/Projects/Code/emacs-from-scratch/OrgFiles/Habits.org"
          "~/Projects/Code/emacs-from-scratch/OrgFiles/Birthdays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  (python-shell-interpreter "python3")
  (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :after python-mode
  :config
  (pyvenv-mode 1))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package term
  :commands term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(cond
 ((eq system-type 'windows-nt)
  (setq explicit-shell-file-name "powershell.exe")
  (setq explicit-powershell.exe-args '())))

(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

;; Log native compilation warnings silently instead of popping up a buffer
(setq native-comp-async-report-warnings-errors 'silent)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

; (use-package dired-single
;  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

;;;; Choix du moteur de complétion : 'corfu ou 'company
(defvar my/completion 'corfu)

;;;; Confort de base
(setq inhibit-startup-screen t
      make-backup-files nil
      auto-save-default nil
      ring-bell-function 'ignore
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(delete-selection-mode 1)
(setq-default indent-tabs-mode nil)
(fset 'yes-or-no-p 'y-or-n-p)
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))
(setenv "PATH" (concat (expand-file-name "~/.cargo/bin:") (getenv "PATH")))

;; ---- exec-path-from-shell: macOS-only (GUI Emacs doesn't inherit shell env) ----
;; On Linux, Emacs usually inherits the environment from the terminal, so this
;; package is not needed unless you launch Emacs from a graphical launcher.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config (exec-path-from-shell-initialize))

(use-package yasnippet
  :config (yas-global-mode 1))
(use-package yasnippet-snippets)

;;;; Complétion : Corfu
(use-package corfu
  :if (eq my/completion 'corfu)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind (:map corfu-map
              ("TAB"   . corfu-next)
              ([tab]   . corfu-next)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous))
  :init (global-corfu-mode 1))

(use-package cape
  :if (eq my/completion 'corfu)
  :init
  (add-to-list 'completion-at-point-functions #'cape-file))

;;;; Complétion : Company (alternative)
(use-package company
  :if (eq my/completion 'company)
  :hook (prog-mode . company-mode)
  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 1)
  (company-tooltip-align-annotations t)
  :bind (:map company-active-map
              ("TAB" . company-complete-selection)
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)))

;;;; Flycheck
(use-package flycheck
  :hook (prog-mode . flycheck-mode)
  :custom (flycheck-check-syntax-automatically '(save mode-enabled idle-change))
  :bind (:map flycheck-mode-map
              ("M-n" . flycheck-next-error)
              ("M-p" . flycheck-previous-error)))

;;;; Rust : rustic (basé sur rust-mode)
(use-package rustic
  :custom
  (rustic-lsp-client 'lsp-mode)
  (rustic-format-trigger 'on-save)
  (rustic-analyzer-command '("rust-analyzer"))
  :bind (:map rustic-mode-map
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status)
              ("C-c C-c b" . rustic-cargo-build)
              ("C-c C-c k" . rustic-cargo-clippy)
              ("C-c C-c t" . rustic-cargo-current-test)
              ("C-c C-c T" . rustic-cargo-test)
              ("C-c C-c R" . rustic-cargo-run)
              ("C-c C-c f" . rustic-format-buffer)
              ("M-?"       . lsp-find-references)
              ("M-j"       . lsp-ui-imenu))
  :config
  (add-hook 'rustic-mode-hook #'my/rust-mode-setup))

(defun my/rust-mode-setup ()
  (setq-local indent-tabs-mode nil
              fill-column 100)
  (when (eq my/completion 'company)
    (setq-local company-backends '(company-capf))))

(use-package toml-mode :mode "\\.toml\\'")
(use-package flycheck-rust
  :after (flycheck rustic)
  :hook (flycheck-mode . flycheck-rust-setup))

;;;; LSP mode
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((rustic-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :init
  (setq lsp-keymap-prefix "C-c l")
  ;; Corfu : on gère le style nous-mêmes (orderless)
  (when (eq my/completion 'corfu)
    (setq lsp-completion-provider :none)
    (defun my/lsp-corfu-setup ()
      (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
            '(orderless)))
    (add-hook 'lsp-completion-mode-hook #'my/lsp-corfu-setup))
  :custom
  (lsp-idle-delay 0.5)
  (lsp-log-io nil)
  (lsp-enable-snippet t)
  (lsp-headerline-breadcrumb-mode)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-signature-auto-activate t)
  (lsp-eldoc-render-all nil)
  (lsp-modeline-diagnostics-enable t)
  (lsp-diagnostics-provider :flycheck)
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  ;; rust-analyzer
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-rust-analyzer-cargo-all-targets t)
  (lsp-rust-analyzer-cargo-load-out-dirs-from-check t)
  (lsp-rust-analyzer-proc-macro-enable t)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-parameter-hints t)
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-completion-add-call-parenthesis t)
  (lsp-rust-analyzer-import-granularity "module")
  (lsp-rust-analyzer-macro-expansion-method 'lsp-rust-analyzer-macro-expansion-default)
  (lsp-rust-analyzer-debug-lens-extra-dap-args
   '(:MIMode "lldb" :miDebuggerPath "rust-lldb"))
  :bind (:map lsp-mode-map
              ("C-c l d" . lsp-find-definition)
              ("C-c l i" . lsp-find-implementation)
              ("C-c l t" . lsp-find-type-definition)
              ("C-c l R" . lsp-rust-analyzer-related-tests)
              ("C-c l e" . lsp-rust-analyzer-expand-macro)
              ("C-c l j" . lsp-rust-analyzer-join-lines)
              ("C-c l h" . lsp-rust-analyzer-inlay-hints-mode)))

(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-code-actions t)
  :bind (:map lsp-ui-mode-map
              ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
              ([remap xref-find-references]  . lsp-ui-peek-find-references)))

(require 'json)
(require 'seq)

;; ---- Platform-specific DAP configuration ----
;; macOS: uses CodeLLDB with lldb-mi from codelldb extension
;; Linux: uses CodeLLDB with system lldb or bundled lldb-mi
;; Architecture: x86_64 vs aarch64 handled by system-configuration

(use-package dap-mode
  :after lsp-mode
  :commands (dap-debug dap-debug-edit-template)
  :custom
  (dap-auto-configure-features '(sessions locals breakpoints expressions repl controls tooltip))
  :config
  (dap-auto-configure-mode 1)
  (require 'dap-codelldb)    ; M-x dap-codelldb-setup (one time)
  (require 'dap-cpptools)    ; required by the "Debug" button ; M-x dap-cpptools-setup (one time)

  ;; ---- Platform-specific lldb-mi path for debug lens ----
  (let ((lldb-mi-path
         (cond
          ((eq system-type 'darwin)
           ;; macOS: relative to dap-cpptools-debug-path
           (expand-file-name "../lldb-mi/bin/lldb-mi"
                             (file-name-directory dap-cpptools-debug-path)))
          ((eq system-type 'gnu/linux)
           ;; Linux: try bundled lldb-mi first, then system lldb-mi
           (let ((bundled (expand-file-name "../lldb-mi/bin/lldb-mi"
                                           (file-name-directory dap-cpptools-debug-path))))
             (if (file-exists-p bundled)
                 bundled
               ;; Fall back to system lldb-mi (common on Debian/Ubuntu)
               "/usr/bin/lldb-mi")))
          (t
           ;; Fallback for other systems
           "/usr/bin/lldb-mi"))))
    (setq lsp-rust-analyzer-debug-lens-extra-dap-args
        `(:MIMode "lldb"
          :miDebuggerPath ,lldb-mi-path
          :stopAtEntry t
          :externalConsole :json-false))))

(defun my/rust--cargo-metadata (root)
  (let ((default-directory root))
    (with-temp-buffer
      (unless (zerop (call-process "cargo" nil '(t nil) nil
                                   "metadata" "--no-deps" "--format-version" "1"))
        (user-error "cargo metadata a échoué dans %s" root))
      (goto-char (point-min))
      (json-parse-buffer :object-type 'alist :array-type 'list))))

(defun my/rust--debug-target ()
  "Retourne (ROOT PACKAGE KIND NAME PROGRAM) pour le buffer courant."
  (let* ((file (or buffer-file-name (user-error "Buffer sans fichier")))
         (root (expand-file-name
                (or (locate-dominating-file file "Cargo.toml")
                    (user-error "Pas de Cargo.toml au-dessus de %s" file))))
         (meta (my/rust--cargo-metadata root))
         (manifest (expand-file-name "Cargo.toml" root))
         (pkg (or (seq-find (lambda (p) (file-equal-p (alist-get 'manifest_path p) manifest))
                            (alist-get 'packages meta))
                  (user-error "Manifeste virtuel : ouvrez un fichier d'un crate membre")))
         (targets (seq-filter
                   (lambda (tg) (seq-intersection '("bin" "example") (alist-get 'kind tg)))
                   (alist-get 'targets pkg)))
         (tg (or (seq-find (lambda (tg) (file-equal-p (alist-get 'src_path tg) file)) targets)
                 (and (= (length targets) 1) (car targets))
                 (and targets
                      (let ((choice (completing-read
                                     "Cible à déboguer : "
                                     (mapcar (lambda (tg) (alist-get 'name tg)) targets)
                                     nil t)))
                        (seq-find (lambda (tg) (string= (alist-get 'name tg) choice)) targets)))
                 (user-error "Aucune cible bin/example dans ce paquet")))
         (name (alist-get 'name tg))
         (example (member "example" (alist-get 'kind tg)))
         (program (expand-file-name
                   (concat (if example "examples/" "") name)
                   (expand-file-name "debug/" (alist-get 'target_directory meta)))))
    (list root (alist-get 'name pkg) (if example "example" "bin") name program)))

;; Force le bouton debug a utiliser ma config pour CoreLLDB
(with-eval-after-load 'lsp-rust
  (advice-add 'lsp-rust-analyzer-debug :override
              (lambda (&rest _) (my/rust-dap-debug))))

(defun my/rust-dap-debug (&optional args)
  "Compile puis débogue (CodeLLDB) la cible du buffer courant.
Avec C-u, demande les arguments du programme."
  (interactive "P")
  (save-some-buffers t)
  (pcase-let* ((`(,root ,pkg ,kind ,name ,program) (my/rust--debug-target))
               (prog-args (if args
                              (vconcat (split-string-and-unquote (read-string "Arguments : ")))
                            [])))
    (dap-debug
     (list :type "lldb"
           :request "launch"
           :name (format "Rust::%s" name)
           :program program
           :cwd (expand-file-name root)
           :args prog-args
           :env (list :RUST_BACKTRACE "1")
           :terminal "console"
           :sourceLanguages ["rust"]
           :dap-compilation (format "cargo build -p %s --%s %s" pkg kind name)
           :dap-compilation-dir root))))

(global-set-key (kbd "C-c d d") #'my/rust-dap-debug)
(global-set-key (kbd "C-c d D") #'dap-debug)
(global-set-key (kbd "C-c d l") #'dap-debug-last)
(global-set-key (kbd "C-c d e") #'dap-debug-edit-template)
(global-set-key (kbd "C-c d t") #'dap-breakpoint-toggle)
(global-set-key (kbd "C-c d c") #'dap-breakpoint-condition)
(global-set-key (kbd "C-c d L") #'dap-breakpoint-log-message)
(global-set-key (kbd "C-c d n") #'dap-next)
(global-set-key (kbd "C-c d s") #'dap-step-in)
(global-set-key (kbd "C-c d o") #'dap-step-out)
(global-set-key (kbd "C-c d r") #'dap-continue)
(global-set-key (kbd "C-c d x") #'dap-eval)
(global-set-key (kbd "C-c d w") #'dap-ui-expressions-add)
(global-set-key (kbd "C-c d q") #'dap-disconnect)
(global-set-key (kbd "C-c d Q") #'dap-delete-all-sessions)
(global-set-key (kbd "C-c d h") #'dap-hydra)

;;;; Raccourcis généraux
(global-set-key (kbd "C-c c") #'compile)
(global-set-key (kbd "C-c e") #'flycheck-list-errors)
(global-set-key (kbd "C-x C-r") #'recentf-open)

;;;; Multi-edition
(use-package multiple-cursors)

(global-set-key (kbd "C-c m n") #'mc/mark-next-like-this)
(global-set-key (kbd "C-c m p") #'mc/mark-previous-like-this)
(global-set-key (kbd "C-c m a") #'mc/mark-all-like-this)
(global-set-key (kbd "C-c m l") #'mc/edit-lines)


(provide 'init-mac-and-linux)
;;; init-mac-and-linux.el ends here
