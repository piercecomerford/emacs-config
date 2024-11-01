;; GNU Emacs configuration

;; All of this should be up here _in this order_ at the top because
;; somehow that prevents weird graphical artefacts and literally cuts
;; the startup time in half. Don't ask me why.
(set-frame-font "monospace 9" nil t)
(set-face-attribute 'variable-pitch nil :family "IBM Plex Serif Light" :height 100)
(add-to-list 'default-frame-alist '(internal-border-width . 20))
(setq frame-inhibit-implied-resize t) ;; not setting this somehow fucks up two birds with one stone.
;; Remove visual clutter
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(toggle-scroll-bar -1)
(blink-cursor-mode 0)
(set-fringe-mode '(1 . 1))
(defun set-local-fringe-width ()
  "Set the fringe width for the current window if in text-mode."
  (when (derived-mode-p 'text-mode)
    (set-window-fringes (selected-window) 16 3)))  ;; Adjust the numbers for left and right fringes
(add-hook 'window-configuration-change-hook 'set-local-fringe-width)

;; suppress garbage collection for faster startup
(setq gc-cons-threshold most-positive-fixnum ; 2^61 bytes
      gc-cons-percentage 0.6)

;; allow some kind of garbage collection anyways.
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold 16777216 ; 16mb
	  gc-cons-percentage 0.1)))

;; doom tells me this is a good idea
(defun doom-defer-garbage-collection-h ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun doom-restore-garbage-collection-h ()
  ;; Defer it so that commands launched immediately after will enjoy the
  ;; benefits
  (run-at-time
   1 (lambda () (setq gc-cons-threshold))))

(add-hook 'minibuffer-setup-hook #'doom-defer-garbage-collection-h)
(add-hook 'minibuffer-exit-hook #'doom-restore-garbage-collection-h)

(setq visible-bell 1)
(setq truncate-string-ellipsis "…")

;; remove trailing whitespace (cos why not ig)
;; why not? because i don't want to make 781 additions
;; when i make a pull request.
;(add-hook 'before-save-hook #'whitespace-cleanup)

;; Don't keep unchanged version of a file in buffer when it's been changed on disk
(global-auto-revert-mode 1)

;; when running external processes (like maxima) emacs
;; likes to give these annoying warnings. but idc.
;; i suppose this is a symptom of bad habits (killing emacs)
(setq confirm-kill-processes nil)

(setq-default word-wrap t)

;; Who wants nice-looking text?
(add-hook 'text-mode-hook
	   (lambda ()
	    (variable-pitch-mode 1)))

;; smoother scrolling
(setq scroll-margin 3
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

(setq inhibit-startup-screen t)
(setq tramp-default-method "ssh") ;; speed up tramp mode
(setq initial-major-mode 'fundamental-mode) ;; better startup speed
(setq initial-scratch-message nil)

(setq frame-title-format '("" "%b - GNU Emacs"))

 ;; Show matching brackets
(show-paren-mode t)
;; paranthesis
;; expression
;; mixed - paren if visible, expr when not
(setq show-paren-style 'paranthesis)

;; Abbreviations (i.e. autocorrect)
(setq abbrev-file-name (expand-file-name "abbrev_defs" user-emacs-directory))
;; Save abbrevs when files are saved
(setq save-abbrevs 'silently)

;; XDG compliance
(defvar user-data-directory
  (concat (getenv "XDG_DATA_HOME") "/emacs/")
  "Directory for user state files.")

(defvar user-state-directory
  (concat (getenv "XDG_STATE_HOME") "/emacs/")
  "Directory for user state files.")

(defvar user-cache-directory
  (concat (getenv "XDG_CACHE_HOME") "/emacs/")
  "Directory for user cache files.")

(dolist (dir (list user-state-directory user-cache-directory user-data-directory))
  (unless (file-exists-p dir)
    (make-directory dir t)))

;; Set backup directory to $XDG_CACHE_HOME/emacs/backups
(setq backup-directory-alist
      `(("." . ,(concat user-cache-directory "backups"))))

;; Enable auto-save and set directory to $XDG_CACHE_HOME/emacs/auto-saves
(setq auto-save-default t)
(setq auto-save-file-name-transforms
      `((".*" ,(concat user-cache-directory "auto-saves/") t)))

;; Set auto-save-list directory to $XDG_CACHE_HOME/emacs/auto-save-list
(setq auto-save-list-file-prefix
      (concat user-cache-directory "auto-save-list/"))

(setq recentf-save-file (expand-file-name "recentf" user-state-directory))
(setq bookmarks-file (expand-file-name "bookmarks" user-data-directory))
(setq bookmark-default-file (expand-file-name "bookmarks" user-data-directory))
(setq nsm-settings-file (expand-file-name "network-security.data" user-data-directory))
(setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" user-data-directory))

;; Set other state-related variables similarly
(setq eshell-history-file-name (expand-file-name "eshell_history" user-state-directory))

(setq transient-levels-file (expand-file-name "transient/levels" user-cache-directory))
(setq transient-values-file (expand-file-name "transient/values" user-cache-directory))
(setq transient-history-file (expand-file-name "transient/history" user-cache-directory))
(setq persistent-scratch-save-file (expand-file-name "persistent-scratch" (concat user-state-directory "persist/")))

(setq url-configuration-directory (expand-file-name "url" user-state-directory))
(setq request-storage-directory (expand-file-name "request" user-state-directory))

;; Save Cursor Position in File
(save-place-mode 1)
(setq save-place-file (expand-file-name "places" user-state-directory))

;; Relative line numbers only for programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setq display-line-numbers-type 'relative
      display-line-numbers-widen t
      display-line-numbers-current-absolute t)

;; visual lines
(global-visual-line-mode)

;; Packages
(require 'package)
;(setq package-user-dir (expand-file-name "elpa" user-data-directory))
(setq package-enable-at-startup nil)
(setq native-comp-eln-load-path (list (expand-file-name "eln-cache" user-cache-directory)))
(setq package-native-compile t)
(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
			 ("gnu"    . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(setq package-quickstart t)

;; Bootstrap 'use-package'
(unless (package-installed-p 'use-package) ; unless it is already installed
  (package-refresh-contents) ; update packages archive
  (package-install 'use-package)) ; and install the most recent version of use-package

;; Themes and icons
(use-package doom-themes
  :ensure t
  :init
  :config
  (setq doom-themes-enable-bold t ;; if nil, bold is universally disabled
	doom-themes-enable-italic t ;; if nil, italics is universally disabled
	doom-gruvbox-light-variant "medium"
	doom-themes-treemacs-enable-variable-pitch nil)
  (doom-themes-visual-bell-config)
;  (doom-themes-org-config)
  (doom-themes-treemacs-config)
  (load-theme 'doom-gruvbox-light t))

(use-package all-the-icons
  :ensure t
  :defer t)

(use-package nerd-icons
  :ensure t
  :defer t)

;; sweet dashboard
(use-package dashboard
  :ensure t
  :config
;  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-startup-banner 'official)
  ;(setq dashboard-set-footer nil)
  (setq dashboard-center-content t)
  (setq dashboard-display-icons-p t)
  (setq dashboard-icon-type 'nerd-icons) ;; use `nerd-icons' package
;  (setq dashboard-icon-type 'all-the-icons) ;; use `all-the-icons' package
  (dashboard-setup-startup-hook))

(use-package page-break-lines
  :ensure t)

;; doom-modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-modal-icon t)
  (setq doom-modeline-enable-word-count t))

(use-package hide-mode-line
  :ensure t
  :defer t
  :bind (("C-c b" . hide-mode-line-mode)))

(use-package pandoc-mode
  :ensure t
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode))

(use-package fountain-mode
  :defer t
  :ensure t)

(use-package rainbow-mode
  :defer t
  :ensure t)

; All the cool IDEs do it
(use-package smartparens
  :defer t
  :ensure t
  :hook (prog-mode . smartparens-mode))

(use-package yasnippet
  :ensure t
  :hook ((text-mode
	  prog-mode
	  conf-mode
	  snippet-mode) . yas-minor-mode-on)
  :init
  (setq ya-snippet-dir (expand-file-name "snippets" user-emacs-directory)))

;; treemacs with all default settings exposed for discovery
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
	  treemacs-deferred-git-apply-delay      0.5
	  treemacs-directory-name-transformer    #'identity
	  treemacs-display-in-side-window        t
	  treemacs-eldoc-display                 t
	  treemacs-file-event-delay              5000
	  treemacs-file-extension-regex          treemacs-last-period-regex-value
	  treemacs-file-follow-delay             0.2
	  treemacs-file-name-transformer         #'identity
	  treemacs-follow-after-init             t
	  treemacs-expand-after-init             t
	  treemacs-git-command-pipe              ""
	  treemacs-goto-tag-strategy             'refetch-index
	  treemacs-indentation                   2
	  treemacs-indentation-string            " "
	  treemacs-is-never-other-window         nil
	  treemacs-max-git-entries               5000
	  treemacs-missing-project-action        'ask
	  treemacs-move-forward-on-expand        nil
	  treemacs-no-png-images                 nil
	  treemacs-no-delete-other-windows       t
	  treemacs-project-follow-cleanup        nil
	  treemacs-persist-file                  (expand-file-name "treemacs-persist" user-cache-directory)
	  treemacs-position                      'left
	  treemacs-read-string-input             'from-child-frame
	  treemacs-recenter-distance             0.1
	  treemacs-recenter-after-file-follow    nil
	  treemacs-recenter-after-tag-follow     nil
	  treemacs-recenter-after-project-jump   'always
	  treemacs-recenter-after-project-expand 'on-distance
	  treemacs-litter-directories            '("/node_modules" "/.venv" "/.cask")
	  treemacs-show-cursor                   nil
	  treemacs-show-hidden-files             nil
	  treemacs-silent-filewatch              nil
	  treemacs-silent-refresh                nil
	  treemacs-sorting                       'alphabetic-asc
	  treemacs-space-between-root-nodes      t
	  treemacs-tag-follow-cleanup            t
	  treemacs-tag-follow-delay              1.5
	  treemacs-user-mode-line-format         nil
	  treemacs-user-header-line-format       nil
	  treemacs-width                         25
	  treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    ;(treemacs-tag-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
		 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
	("M-0"       . treemacs-select-window)
	("C-x t 1"   . treemacs-delete-other-windows)
	("C-x t t"   . treemacs)
	("C-x t B"   . treemacs-bookmark)
	("C-x t C-t" . treemacs-find-file)
	("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :after (treemacs dired)
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package minimap
  :defer t
  :ensure t)

(use-package undo-tree
  :ensure t
  :config
  (setq undo-tree-history-directory-alist `(("." . ,(concat user-cache-directory "undo"))))
  (global-undo-tree-mode))

(use-package magit
  :ensure t
  :defer t)

;; vim mode
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
	evil-insert-state-cursor '(bar . 1)
	evil-want-fine-undo t
	evil-want-keybinding nil
	evil-respect-visual-line-mode t)
  (require 'evil-vars)
  (evil-set-undo-system 'undo-tree)
  :config
  (evil-mode))

(use-package evil-colemak-basics
  :ensure t
  :config
  (global-evil-colemak-basics-mode)
  ;; A few awful things to get window management to work.
  (define-key evil-window-map "n" 'evil-window-down)
  (define-key evil-window-map "N" 'evil-window-move-very-bottom)
  (define-key evil-window-map (kbd "C-S-n") 'evil-window-move-very-bottom)
  (define-key evil-window-map "e" 'evil-window-up)
  (define-key evil-window-map "E" 'evil-window-move-very-top)
  (define-key evil-window-map (kbd "C-S-e") 'evil-window-move-very-top)
  (define-key evil-window-map "i" 'evil-window-right)
  (define-key evil-window-map "I" 'evil-window-move-far-right)
  (define-key evil-window-map (kbd "C-S-i") 'evil-window-move-far-right)
  ;; Kreate new window
  (define-key evil-window-map "k" 'evil-window-new)
  (define-key evil-window-map "\C-k" 'evil-window-new))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; To make citations properly
;; except it doesn't work atm
;;(use-package citeproc
;;  :after (org)
;;  :ensure t
;;  :defer t)

;; Meant to be better than DocView
;(use-package pdf-tools
;  :ensure t)

;; LaTeX
(use-package tex
  :config
  (setq TeX-PDF-mode t
	TeX-view-program-selection '((output-pdf "Zathura"))
	TeX-source-correlate-mode t
	TeX-source-correlate-start-server t)
  :ensure auctex)

;; org-moment
(use-package org
  :defer t
  :hook (org-mode . visual-line-mode)
  :init
  (org-babel-do-load-languages 'org-babel-load-languages '((python . t) (C . t) (octave . t)))
  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
  :config
  (setq org-hide-leading-stars             t
	org-indent-mode-turns-on-hiding-stars nil
	org-confirm-babel-evaluate nil
	org-hidden-keywords '(title author)
	org-hide-macro-markers             t
	org-ellipsis                       "  " ;; folding symbol
	org-image-actual-width             550
	org-redisplay-inline-images        t
	org-display-inline-images          t
	org-startup-with-inline-images     "inlineimages"
	org-pretty-entities                t
	org-fontify-whole-heading-line     t
	org-fontify-done-headline          t
	org-fontify-quote-and-verse-blocks t
	org-startup-indented               nil
	org-startup-align-all-tables       t
	org-use-property-inheritance       t
	org-list-allow-alphabetical        t
	org-M-RET-may-split-line           nil
	org-src-window-setup               'split-window-below
	org-src-fontify-natively           t
	org-src-tab-acts-natively          t
	org-src-preserve-indentation       t
	org-log-done                       'time)
  ;; set basic title font
  (set-face-attribute 'org-level-8 nil :foreground 'unspecified :weight 'normal :inherit 'default)
  ;; Low levels are unimportant => no scaling
  (set-face-attribute 'org-level-7 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-6 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-5 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-4 nil :inherit 'org-level-8)
  ;; Top ones get scaled the same as in LaTeX (\large, \Large, \LARGE)
  (set-face-attribute 'org-level-3 nil :foreground 'unspecified :inherit 'org-level-8 :height 1.2) ;\large
  (set-face-attribute 'org-level-2 nil :foreground 'unspecified :slant 'italic :inherit 'org-level-8 :height 1.44) ;\Large
  (set-face-attribute 'org-level-1 nil :foreground 'unspecified :inherit 'org-level-8 :height 1.728) ;\LARGE
  ;; Only use the first 4 styles and do not cycle.
  (setq org-cycle-level-faces nil)
  (setq org-n-level-faces 4)
  ;; Document Title, (\huge)
  (set-face-attribute 'org-document-title nil
		      :height 2.074
		      :foreground 'unspecified
		      :inherit 'org-level-8)
  (custom-theme-set-faces
   'user
   '(org-block ((t (:inherit fixed-pitch))))
   '(org-code ((t (:inherit (shadow fixed-pitch)))))
   '(org-document-info ((t (:foreground "dark orange"))))
   '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
   '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
   '(org-link ((t (:foreground "royal blue" :underline t))))
   '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-property-value ((t (:inherit fixed-pitch))) t)
   '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
   '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))
  (setq org-agenda-include-diary t)
  )

(use-package org-ref
  :ensure t
  :defer t
  )

(use-package org-bullets
  :ensure t
  :defer t
  :after org
  :config
  (setq org-bullets-bullet-list '(" ")))

(use-package evil-org
  :after (org)
  :ensure t
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

; causes problems i can't figure out
;(use-package mixed-pitch
;  :after org
;  :ensure t
;  :hook
;  (org-mode           . mixed-pitch-mode)
;  (emms-browser-mode  . mixed-pitch-mode)
;  (emms-playlist-mode . mixed-pitch-mode)
;  (add-hook 'org-agenda-mode-hook (lambda () (mixed-pitch-mode -1))))

(use-package valign
  :ensure t
  :after org
  :config
  (setq valign-fancy-bar t)
  (add-hook 'org-mode-hook #'valign-mode))

(use-package org-appear
  :ensure t
  :after org
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis   t
	org-hide-emphasis-markers t
	org-appear-autokeywords   t
	org-appear-autolinks      t
	org-appear-autoentities   t
	org-appear-autosubmarkers t
	org-appear-inside-latex   t)
  (run-at-time nil nil #'org-appear--set-elements))

; (use-package ob-latex-as-png
;   :after org
;   :ensure t
;   :defer t
;   :init
;   (add-to-list 'org-babel-load-languages '(latex-as-png . t)))

(use-package org-fragtog
  :ensure t
  :defer t
  :after org
  :hook (org-mode . org-fragtog-mode))

(use-package org-mime
  :ensure t
  :defer t
  :after org)

;; for rss feeds
(use-package elfeed
  :ensure t
  :defer t
  :config
  (setq elfeed-feeds
	'(
        "https://www.irishtimes.com/arc/outboundfeeds/feed-irish-news/?from=0&size=20"
	"https://www.rte.ie/feeds/rss/?index=/news/"
	"https://www.independent.ie/rss/section/ada62966-6b00-4ead-a0ba-2c179a0730b0"
	"https://letterboxd.com/moviesoftheweek/rss/"
	"https://letterboxd.com/salofamily/rss/"
        "https://voidlinux.org/atom.xml"
	))
  (setq elfeed-db-directory (expand-file-name "elfeed" user-data-directory))
  :bind ("C-x w" . elfeed))

(use-package smtpmail
  :config
  (setq smtpmail-debug-info t
	smtpmail-debug-verbose t
	auth-sources `(,(concat user-emacs-directory "authinfo.gpg")))
  :ensure nil)

;; mu4e
(use-package mu4e
  :after smtpmail
  :ensure nil
  :commands (mu4e mu4e-compose-new)
  :bind (("<f12>" . mu4e))
  :config
  (require 'mu4e-icalendar)
  (mu4e-icalendar-setup)
  (setq gnus-icalendar-org-capture-file "~/doc/notes.org")
  (setq gnus-icalendar-org-capture-headline '("Calendar"))
  (gnus-icalendar-org-setup)
  (setq mu4e-get-mail-command "mbsync -c $XDG_CONFIG_HOME/isync/mbsyncrc -a"
	display-buffer-alist '(("\\*mu4e-main\\*" display-buffer-same-window))
	mail-user-agent 'mu4e-user-agent
	mu4e-use-fancy-chars t
	mu4e-split-view 'horizontal
	mu4e-maildir "~/var/mail"
	mu4e-view-prefer-html t
	mu4e-update-interval 180
	mu4e-headers-auto-update t
	mu4e-compose-signature-auto-include nil
	mu4e-view-show-images t
	;; don't save message to Sent Messages, IMAP takes care of this
	mu4e-sent-messages-behavior 'delete
	;;rename files when moving
	;;NEEDED FOR MBSYNC
	mu4e-change-filenames-when-moving t
	;;set up queue for offline email
	;;use mu mkdir  ~/Maildir/acc/queue to set up first
	smtpmail-queue-mail nil  ;; start in normal mode
	message-send-mail-function 'smtpmail-send-it
	;;from the info manual
	mu4e-attachment-dir  "~/tmp"
	message-kill-buffer-on-exit t
	mu4e-compose-dont-reply-to-self t
	;; convert org mode to HTML automatically
	org-mu4e-convert-to-html t
	mu4e-view-show-addresses 't
	mu4e-confirm-quit nil
	mu4e-context-policy 'pick-first
	mu4e-compose-context-policy 'always-ask)
;; Multiple accounts
  (setq mu4e-contexts
	`(,(make-mu4e-context
	    :name "TCD"
	    :match-func
	    (lambda (msg)
	      (when msg
		(mu4e-message-contact-field-matches msg
					     '(:from :to :cc :bcc) "comerfpi@tcd.ie")))
	    :vars `((user-mail-address . "comerfpi@tcd.ie")
		    (user-full-name . "Pierce Comerford")
		    (smtpmail-default-smtp-server . "smtp.gmail.com")
		    (smtpmail-smtp-server . "smtp.gmail.com")
		    (smtpmail-smtp-service . 587)
		    (smtpmail-stream-type . starttls)
		    (starttls-use-gnutls . t)
		    (mu4e-sent-folder . "/comerfpi-tcd/[Gmail]/Sent Mail")
		    (mu4e-drafts-folder . "/comerfpi-tcd/[Gmail]/Drafts")
		    (mu4e-trash-folder . "/comerfpi-tcd/[Gmail]/Bin")
		    (mu4e-compose-format-flowed . t)
		    (mu4e-maildir-shortcuts . ( ("/comerfpi-tcd/INBOX"             . ?i)
						("/comerfpi-tcd/[Gmail]/Sent Mail" . ?s)
						("/comerfpi-tcd/[Gmail]/Bin"       . ?t)
						("/comerfpi-tcd/[Gmail]/Spam"      . ?a)
						("/comerfpi-tcd/[Gmail]/Starred"   . ?r)
						("/comerfpi-tcd/[Gmail]/Drafts"    . ?d)
						))
		    (mu4e-compose-signature .
		      (concat "Best regards,\n"
			      "Pierce Comerord, No. 21364727")))
	    )
	  ,(make-mu4e-context
	    :name "Disroot"
	    :match-func
	    (lambda (msg)
	      (when msg
		(mu4e-message-contact-field-matches msg
					     '(:from :to :cc :bcc) "pc1@disroot.org")))
	    :vars `((user-mail-address . "pc1@disroot.org")
		    (smtpmail-smtp-server . "disroot.org")
		    (smtpmail-smtp-service . 587)
		    (smtpmail-stream-type . starttls)
		    (mu4e-sent-folder . "/pc1-disroot/Sent")
		    (mu4e-drafts-folder . "/pc1-disroot/Drafts")
		    (mu4e-trash-folder . "/pc1-disroot/Trash")
		    (mu4e-sent-messages-behavior . sent)
		    (mu4e-maildir-shortcuts . ( ("/pc1-disroot/Inbox"             . ?i)
						("/pc1-disroot/Sent" . ?s)
						("/pc1-disroot/Trash"       . ?t)
						("/pc1-disroot/Archive"  . ?a)
						("/pc1-disroot/Junk"   . ?r)
						("/pc1-disroot/Drafts"    . ?d)
						))
		    (mu4e-compose-signature .
		      (concat "Best regards,\n"
			      "Pierce")))
	    )
;	  ,(make-mu4e-context
;	    :name "P-TRIUMF"
;	    :match-func
;	    (lambda (msg)
;	      (when msg
;		(mu4e-message-contact-field-matches msg
;					     '(:from :to :cc :bcc) "pcomerford@triumf.ca")))
;	    :vars `((user-mail-address . "pcomerford@triumf.ca")
;		    (user-full-name . "Pierce Comerford")
;		    (smtpmail-default-smtp-server . "smtp-mail.outlook.com")
;		    (smtpmail-smtp-server . "smtp-mail.outlook.com")
;		    (smtpmail-smtp-service . 587)
;		    (smtpmail-stream-type . starttls)
;		    (starttls-use-gnutls . t)
;		    (mu4e-sent-folder . "/pcomerford-triumf/Sent Items")
;		    (mu4e-drafts-folder . "/pcomerford-triumf/Drafts")
;		    (mu4e-trash-folder . "/pcomerford-triumf/Trash")
;		    (mu4e-compose-format-flowed . t)
;		    (mu4e-maildir-shortcuts . ( ("/pcomerford-triumf/Inbox"             . ?i)
;						("/pcomerford-triumf/Sent Items" . ?s)
;						("/pcomerford-triumf/Trash"       . ?t)
;						("/pcomerford-triumf/Junk Email"      . ?a)
;						("/pcomerford-triumf/Drafts"    . ?d)
;						))
;		    (mu4e-compose-signature .
;		      (concat "Best regards,\n"
;			      "Pierce Comerord")))
;	    )
	  ,(make-mu4e-context
	    :name "GMX"
	    :match-func
	    (lambda (msg)
	      (when msg
		(mu4e-message-contact-field-matches msg
					     '(:from :to :cc :bcc) "pc13@gmx.com")))
	    :vars `((user-mail-address . "pc13@gmx.com")
		    (smtpmail-smtp-server . "mail.gmx.com")
		    (smtpmail-smtp-service . 587)
		    (smtpmail-stream-type . starttls)
		    (mu4e-sent-folder . "/pc13-gmx/Sent")
		    (mu4e-drafts-folder . "/pc13-gmx/Drafts")
		    (mu4e-trash-folder . "/pc13-gmx/Trash")
		    (mu4e-sent-messages-behavior . sent)
		    (mu4e-maildir-shortcuts . ( ("/pc13-gmx/Inbox"             . ?i)
						("/pc13-gmx/Sent" . ?s)
						("/pc13-gmx/Trash"       . ?t)
						("/pc13-gmx/Junk"   . ?r)
						("/pc13-gmx/Drafts"    . ?d)
						))
		    (mu4e-compose-signature .
		      (concat "Best regards,\n"
			      "Pierce")))
	    )

)))

;; oauth2 authentication
(use-package oauth2
  :after smtpmail
  :ensure t
  :init
  (cl-defmethod smtpmail-try-auth-method
    (process (_mech (eql xoauth2)) user password)
    (smtpmail-command-or-throw
     process
     (concat "AUTH XOAUTH2 " (replace-regexp-in-string "\n+" "" (shell-command-to-string (concat "oauth.py --authstr " user))))))
  (add-to-list 'smtpmail-auth-supported 'xoauth2))

;; Matrix Client
(use-package ement
  :ensure t
  :defer t
  :config
  (defun ement ()
    (interactive)
    ;; Pantalaimon for E2EE support (probably not installed because it needs dbus)
    (let* ((pantalaimon-command "pantalaimon")
	   (pantalaimon-buffer "*pantalaimon*"))
      ;; Start Pantalaimon process
      (unless (get-buffer pantalaimon-buffer)
	(start-process pantalaimon-buffer pantalaimon-buffer pantalaimon-command))
      ;; Wait for Pantalaimon to start
      (sleep-for 2)
      (ement-connect :user-id "@pc1:matrix.org"
		     :uri-prefix "http://localhost:8009")))
  ;; Define a function to kill the Pantalaimon process
  (defun my-kill-pantalaimon ()
    (let ((pantalaimon-buffer "*pantalaimon*"))
      (when (get-buffer pantalaimon-buffer)
	(let ((pantalaimon-process (get-buffer-process pantalaimon-buffer)))
	  (when pantalaimon-process
	    (set-process-query-on-exit-flag pantalaimon-process nil))
	  (kill-buffer pantalaimon-buffer)))))
  ;; Add the function to the `ement-disconnect-hook`
  (add-hook 'ement-disconnect-hook 'my-kill-pantalaimon)
  :commands (ement))

;; Spell-cheque
(use-package ispell
  :defer t
  :config
  (add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_EXAMPLE" . "#\\+END_EXAMPLE"))
  (setq ispell-program-name "aspell"
	ispell-dictionary "british"
	ispell-extra-args '("--sug-mode=ultra" "--run-together")
	ispell-aspell-dict-dir (ispell-get-aspell-config-value "dict-dir")
	ispell-aspell-data-dir (ispell-get-aspell-config-value "data-dir")
	ispell-personal-dictionary (expand-file-name (concat "ispell/" ispell-dictionary ".pws") user-emacs-directory)))

(use-package flyspell
  :defer t
  :ensure t
  :init
  (require 'ispell) ;; force loading ispell
  :config
  (setq flyspell-issue-welcome-flag nil
	flyspell-issue-message-flag nil)
  :hook
  (text-mode . flyspell-mode)
  (mu4e-compose-mode . flyspell-mode))

(use-package flycheck
  :defer t
  :ensure t)

; Python IDE
(use-package elpy
  :ensure t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable)
  :config
  (setq elpy-rpc-virtualenv-path (expand-file-name "elpy" user-data-directory))
;  :config
  ;(setq python-shell-interpreter "jupyter"
;	python-shell-interpreter-args "console --simple-prompt"
;	python-shell-prompt-detect-failure-warning nil)
;  (add-to-list 'python-shell-completion-native-disabled-interpreters
;	       "jupyter")
  )

;; Anki
(use-package org-anki
  :ensure t
  :after org)

;(use-package maxima
;  :ensure t
;  :init
;  (add-hook 'maxima-mode-hook #'maxima-hook-function)
;  (add-hook 'maxima-inferior-mode-hook #'maxima-hook-function))

; Computer Algebra System
 (use-package maxima
   :ensure t
   :load-path "/usr/share/emacs/site-lisp/"
   :init
   (add-to-list 'auto-mode-alist
		 (cons "\\.mac\\'" 'maxima-mode))
   (add-to-list 'interpreter-mode-alist
		 (cons "maxima" 'maxima-mode))
 ;  (autoload 'maxima-mode "maxima" "Maxima mode" t)
   (autoload 'imaxima "imaxima" "Frontend for maxima with Image support" t)
 ;  (autoload 'maxima "maxima" "Maxima interaction" t)
 ;  (autoload 'imath-mode "imath" "Imath mode for math formula input" t)
   :config
   (setq imaxima-use-maxima-mode-flag t
	imaxima-fnt-size "large"
	imaxima-pt-size 12
	org-babel-maxima-command "maxima")
 ;  (add-hook 'maxima-mode-hook #'maxima-hook-function)
 ;  (add-hook 'maxima-inferior-mode-hook #'maxima-hook-function)
   )

; OpenSCAD
(use-package scad-mode
  :ensure t
  :defer t)

; For CERN ROOT data analysis framework
(use-package cern-root-mode
  :ensure t
  :defer t
  :bind (:map c++-mode-map
	     (("C-c C-c" . cern-root-eval-defun)
	      ("C-c C-b" . cern-root-eval-buffer)
	      ("C-c C-l" . cern-root-eval-file)
	      ("C-c C-r" . cern-root-eval-region)))
  )

; ChatGPT
;(use-package chatgpt-shell
;  :ensure t
;  :config
;  (setq chatgpt-shell-openai-key
;	(lambda ()
;	  (nth 0 (process-lines "pass" "show" "openai.com/api-comerfpi-1"))))
;  )

; Auto-completion
(use-package company
  :ensure t
  :defer t
  :init
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-math
  :ensure t
  :init
  (setq company-math-disallow-unicode-symbols-in-faces nil))

;(use-package company-maxima
;  :ensure t
;  :init
;  (with-eval-after-load 'company
;  (add-to-list 'company-backends '(company-maxima-symbols company-maxima-libraries))))

(use-package lsp-mode
  :ensure t
  :defer t)

(use-package gnuplot
  :ensure t
  :defer t)

;; Get rid of custom-clutter
(setq-default custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) ; Don’t forget to load it, we still need it
  (load custom-file))
