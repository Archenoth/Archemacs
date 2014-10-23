;; SSL Support (For ERC primarily)
(require 'tls)

;; Speaking of which... ERC stuff
(add-to-list 'load-path "~/.emacs.d/erc-extras" t)
(load "~/.emacs.d/extern/erc-nick-notify.el")
;(load "~/.emacs.d/extern/erc-tab.el")
(autoload 'erc-nick-notify-mode "erc-nick-notify"
  "Minor mode that calls `erc-nick-notify-cmd' when his nick gets
mentioned in an erc channel" t)
(eval-after-load 'erc '(erc-nick-notify-mode t))

;;;; Hooks
;; Flymake
(add-hook 'perl-mode-hook (lambda () (flymake-mode t)))
(add-hook 'php-mode-hook (lambda () (flymake-mode t)))

;; Org Mode
(add-hook
 'org-mode-hook
 (lambda ()
   (progn
     (flyspell-mode t)
     (auto-fill-mode t)
     (require 'org-latex)
     (setq-default indent-tabs-mode nil)
     (setq org-src-fontify-natively t)
     (setq org-export-latex-listings 'minted)
     (add-to-list 'org-export-latex-packages-alist '("" "minted"))
     ;; LanguageTool setup
     (require 'langtool)
     (setq langtool-language-tool-jar
           "/home/archenoth/Documents/apps/LanguageTool/LanguageTool.jar"))))

;; Feature mode
(add-hook 'feature-mode-hook
          (lambda ()
            (local-set-key (kbd "C-s-r") 'jump-to-cucumber-step)))

;; Making boolean question less annoying
(defalias 'yes-or-no-p 'y-or-n-p)

;; Post-package-loading hook
(defun package-config ()
  ;;;; Package Requires
  ;; Nurumacs, base16-tomorrow theme, and powerline... Bad in NOX though.
  (if (display-graphic-p)
      (progn
        (powerline-center-theme)
        (require 'nurumacs)
        (load-theme 'base16-tomorrow)))

  ;; Expand region
  (require 'expand-region)
  (global-set-key (kbd "s-SPC") 'er/expand-region)
  (global-set-key (kbd "s-S-SPC") 'er/contract-region)

  ;; Multiple-cursors
  (require 'multiple-cursors)
  (global-set-key (kbd "s-s") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-s-s") 'mc/mark-all-like-this)
  (global-set-key (kbd "M-s-s") 'mc/mark-next-symbol-like-this)
  (global-set-key (kbd "s-S") 'mc/mark-sgml-tag-pair)

  ;; Robe mode, flymake-ruby etc... Ruby support
  (add-hook 'ruby-mode-hook 'robe-mode)
  (add-hook 'ruby-mode-hook 'flymake-ruby-load)
  (add-hook 'enh-ruby-mode-hook
            (lambda ()
              (robe-mode)
              (add-to-list 'ac-sources 'ac-source-robe)
              (add-to-list 'ac-sources 'ac-source-rsense-method)
              (add-to-list 'ac-sources 'ac-source-rsense-constant)))

  ;; Jedi, for Python sweetness
  (add-hook 'python-mode-hook
            (lambda ()
              (setq jedi:server-command '("/usr/local/bin/jediepcserver"))
              (jedi:ac-setup)
              (setq jedi:complete-on-dot t)))

  ;; Projectile
  (require 'grizzl)
  (setq projectile-enable-caching t)
  (setq projectile-completion-system 'grizzl)
  (global-set-key (kbd "s-f") 'helm-projectile)
  (global-set-key (kbd "C-s-f") 'helm-projectile-all)

  ;; JavaScript
  (require 'flymake-jshint)
  (require 'js2-refactor)
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-hook 'js2-mode-hook
	    (lambda ()
	      (ac-js2-mode)
	      (local-set-key (kbd "s-<f3>") #'ac-js2-jump-to-definition)))
  
  ;; C and C++
  (add-hook 'c-mode-hook
          (lambda ()
	    (flymake-mode)
	    (semantic-mode)
	    (local-set-key (kbd "s-<f3>") #'semantic-ia-fast-jump)
            (setq ac-sources '(ac-source-semantic
			       ac-source-yasnippet))))

  ;; Common Lisp
  ;; Set your lisp system and, optionally, some contribs Common Lisp
  (setq inferior-lisp-program "/usr/bin/sbcl")
  (setq slime-contribs '(slime-fancy))
  (add-hook 'slime-mode-hook 'set-up-slime-ac)
  (add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
  (eval-after-load "auto-complete"
    '(add-to-list 'ac-modes 'slime-repl-mode))

  ;; ELISP
  (require 'erefactor)
  ;; Hook for all ELISP modes
  (defun el-hook ()
    (define-key emacs-lisp-mode-map "\C-c\C-v" erefactor-map)
    (erefactor-lazy-highlight-turn-on)
    (eldoc-mode t))
  ;; And assigning to said modes
  (add-hook 'emacs-lisp-mode-hook 'el-hook)
  (add-hook 'lisp-interaction-mode-hook 'el-hook)

  ;; CIDER, Clojure
  (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)

  ;; Web Mode for HTML, JSPs, etc...
  (add-to-list 'auto-mode-alist '("\\.[sj]?html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.phtml$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php[34]?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb$" . web-mode))
  (setq web-mode-engines-alist  '(("jsp" . "\\.tag\\'")))

  (defun web-mode-hook ()
    "Hooks for Web mode."
    (setq web-mode-html-offset 2)
    (setq web-mode-css-offset 2)
    (setq web-mode-script-offset 2)
    (emmet-mode 1)
    (setq emmet-indentation 2)
    (yas-minor-mode 1))
  (add-hook 'web-mode-hook 'web-mode-hook)
  (add-hook 'sgml-mode-hook 'ac-emmet-html-setup)
  (add-hook 'css-mode-hook 'ac-emmet-css-setup)

  ;; Start global package modes
  (ac-config-default)
  (add-to-list 'ac-modes 'web-mode)

  (projectile-global-mode))

(add-hook 'after-init-hook 'package-config)

;;;; Variables
(setq create-lockfiles nil) ;; Nasty at times

;; Markdown
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

;; Package Manager URLs
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			 ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("melpa" . "http://melpa.milkbox.net/packages/")))

;;;; Custom keybindings
(define-key global-map (kbd "s-/") 'ace-jump-mode)
(define-key global-map (kbd "s-?") 'ace-jump-char-mode)
(define-key global-map (kbd "<f5>") 'compile)

;; Auto-backups
(setq backup-by-copying t      ; don't clobber symlinks
      backup-directory-alist
      '(("." . "~/.saves"))    ; don't litter my fs tree
      delete-old-versions t 
      kept-new-versions 6
      kept-old-versions 2
      version-control t)       ; use versioned backups
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Start global modes
(show-paren-mode)

;;;
;; Stuff generated by the editor, no touchy!
;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(cgs-root-markers (quote (".git" ".svn" ".hg" ".bzr" ".cucumber")))
 '(cgs-step-search-path "/features/**/*.rb")
 '(compilation-message-face (quote default))
 '(custom-safe-themes (quote ("e53cc4144192bb4e4ed10a3fa3e7442cae4c3d231df8822f6c02f1220a0d259a" default)))
 '(eclim-eclipse-dirs (quote ("~/opt/eclipse")))
 '(eclim-executable "/opt/eclipse/eclim")
 '(erc-autojoin-channels-alist (quote (("irc.freenode.net" "#mimiga"))))
 '(erc-modules (quote (autojoin button completion dcc fill irccontrols list log match menu move-to-prompt netsplit networks noncommands readonly ring stamp spelling track unmorse)))
 '(erc-nick "Mawile")
 '(erc-nick-uniquifier "_The_Second")
 '(erc-port 7000)
 '(erc-server "irc.freenode.net")
 '(erc-try-new-nick-p t)
 '(fci-rule-color "#383838")
 '(feature-align-steps-after-first-word t)
 '(feature-cucumber-command "cucumber {options} \"{feature}\" -verbose")
 '(feature-indent-level 2)
 '(flymake-allowed-file-name-masks (quote (("\\.\\(?:c\\(?:pp\\|xx\\|\\+\\+\\)?\\|CC\\)\\'" flymake-simple-make-init) ("\\.xml\\'" flymake-xml-init) ("\\.html?\\'" flymake-xml-init) ("\\.cs\\'" flymake-simple-make-init) ("\\.p[ml]\\'" flymake-perl-init) ("\\.php[345]?\\'" flymake-php-init) ("\\.h\\'" flymake-master-make-header-init flymake-master-cleanup) ("\\.java\\'" flymake-simple-make-java-init flymake-simple-java-cleanup) ("[0-9]+\\.tex\\'" flymake-master-tex-init flymake-master-cleanup) ("\\.tex\\'" flymake-simple-tex-init) ("\\.idl\\'" flymake-simple-make-init) ("\\.js\\'" flymake-jshint-load))))
 '(fringe-mode 0 nil (fringe))
 '(helm-default-external-file-browser "nautilus")
 '(helm-input-idle-delay 0.1)
 '(helm-never-delay-on-input t)
 '(highlight-changes-colors (quote ("#FD5FF0" "#AE81FF")))
 '(highlight-tail-colors (quote (("#49483E" . 0) ("#67930F" . 20) ("#349B8D" . 30) ("#21889B" . 50) ("#968B26" . 60) ("#A45E0A" . 70) ("#A41F99" . 85) ("#49483E" . 100))))
 '(inhibit-startup-screen t)
 '(js2-basic-offset 4)
 '(js2-global-externs (quote ("$" "location" "window" "_")))
 '(js2-highlight-level 3)
 '(js2-include-node-externs t)
 '(linum-format " %7i ")
 '(magit-diff-use-overlays nil)
 '(minimap-resizes-buffer t)
 '(minimap-update-delay 0.2)
 '(minimap-width-fraction 0.2)
 '(org-todo-keywords (quote ((sequence "TODO(t)" "|" "DONE(d)") (sequence "REPORT(r)" "BUG(b)" "KNOWNCAUSE(k)" "|" "FIXED(f)") (sequence "|" "CANCELLED(c)"))))
 '(projectile-generic-command "find -type f -print0 -exec grep -Il . {} \\;")
 '(projectile-git-command "git ls-files -zco --exclude-standard")
 '(show-paren-mode t)
 '(sql-mysql-options (quote ("-n")))
 '(syslog-debug-face (quote ((t :background unspecified :foreground "#A1EFE4" :weight bold))))
 '(syslog-error-face (quote ((t :background unspecified :foreground "#F92672" :weight bold))))
 '(syslog-hour-face (quote ((t :background unspecified :foreground "#A6E22E"))))
 '(syslog-info-face (quote ((t :background unspecified :foreground "#66D9EF" :weight bold))))
 '(syslog-ip-face (quote ((t :background unspecified :foreground "#E6DB74"))))
 '(syslog-su-face (quote ((t :background unspecified :foreground "#FD5FF0"))))
 '(syslog-warn-face (quote ((t :background unspecified :foreground "#FD971F" :weight bold))))
 '(tool-bar-mode nil)
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map (quote ((20 . "#BC8383") (40 . "#CC9393") (60 . "#DFAF8F") (80 . "#D0BF8F") (100 . "#E0CF9F") (120 . "#F0DFAF") (140 . "#5F7F5F") (160 . "#7F9F7F") (180 . "#8FB28F") (200 . "#9FC59F") (220 . "#AFD8AF") (240 . "#BFEBBF") (260 . "#93E0E3") (280 . "#6CA0A3") (300 . "#7CB8BB") (320 . "#8CD0D3") (340 . "#94BFF3") (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(weechat-color-list (quote (unspecified "#272822" "#49483E" "#A20C41" "#F92672" "#67930F" "#A6E22E" "#968B26" "#E6DB74" "#21889B" "#66D9EF" "#A41F99" "#FD5FF0" "#349B8D" "#A1EFE4" "#F8F8F2" "#F8F8F0"))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Inconsolata" :foundry "unknown" :slant normal :weight normal :height 98 :width normal))))
 '(erm-syn-errline ((t (:underline (:color "red" :style wave)))) t)
 '(erm-syn-warnline ((t (:underline (:color "yellow" :style wave)))) t)
 '(flymake-errline ((t (:underline (:color "red" :style wave)))))
 '(flymake-warnline ((t (:underline (:color "yellow" :style wave)))))
 '(helm-candidate-number ((t (:background "#733" :foreground "white smoke"))))
 '(js2-error ((t (:foreground "red" :underline (:color foreground-color :style wave)))))
 '(js2-external-variable ((t (:foreground "orange" :underline t))))
 '(mode-line ((t (:foreground "#030303" :background "#bdbdbd" :box nil))))
 '(mode-line-inactive ((t (:foreground "#f9f9f9" :background "#666666" :box nil))))
 '(powerline-active1 ((t (:inherit mode-line :background "grey22" :foreground "gainsboro")))))

;; And finally, load more private configuration
(load "~/.emacs.d/dotemacs/private.el")
