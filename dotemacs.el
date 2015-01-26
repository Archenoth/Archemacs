;;; External links... The part you need to pay attention to if you aren't me.
;; http://tkf.github.io/emacs-jedi/latest/
(setq jedi:server-command '("/usr/local/bin/jediepcserver"))
;; http://www.clisp.org/
(setq inferior-lisp-program "/usr/bin/clisp")
;; You can get this from here: https://languagetool.org/
(setq langtool-language-tool-jar
             "/home/archenoth/Documents/apps/LanguageTool/LanguageTool.jar")


;;; The rest should be independant

;; Package Manager URLs
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			 ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("melpa" . "http://melpa.milkbox.net/packages/")))


;; SSL Support (For ERC primarily)
(require 'tls)

;;;; Hooks
;; Flymake
(add-hook 'perl-mode-hook (lambda () (flymake-mode t)))
(add-hook 'php-mode-hook (lambda () (flymake-mode t)))


;; Making boolean question less annoying
(defalias 'yes-or-no-p 'y-or-n-p)


;; My little package checker and installer
(defun check-packages (&rest packages)
  "Checks if the passed in packages are installed, and installs
the ones that are not."
  (cl-labels
      ((install (packages refresh)
                (when packages
                  (let ((package (car packages))
                        (rest (cdr packages)))
                    (if (package-installed-p package)
                        (install rest refresh)
                      (when refresh (package-refresh-contents)
                            (package-install package)
                            (install rest nil)))))))
    (install packages t)))


;; Post-package-loading hook
(defun package-config ()
  ;; Ensuring packages are installed
  (check-packages 'yasnippet 'web-mode 'undo-tree 'sublime-themes
'sr-speedbar 'speed-type 'sokoban 'slime 'skewer-mode
'simple-httpd 's 'rsense 'robe 'queue 'python-environment
'projectile 'powerline 'popup 'plsql 'pkg-info 'php-mode 'pcre2el
'paredit 'nurumacs 'noflet 'multiple-cursors 'markdown-mode
'markdown-mode+ 'magit 'lua-mode 'let-alist 'langtool
'js2-refactor 'js2-mode 'jedi 'inf-ruby 'htmlize
'helm-projectile-all 'helm-projectile 'helm-emmet 'helm 'grizzl
'graphviz-dot-mode 'goto-last-change 'goto-chg 'git-rebase-mode
'git-commit-mode 'flymake-ruby 'flymake-jshint 'flymake-easy
'flymake-csslint 'flycheck 'feature-mode 'f 'expand-region 'evil
'espuds 'erefactor 'erc-nick-notify 'epl 'epc 'enh-ruby-mode
'emmet-mode 'emacs-eclim 'ecukes 'deferred 'dash
'cucumber-goto-step 'ctable 'concurrent 'commander 'clojure-mode
'cider 'base16-theme 'auto-complete 'async 'apache-mode 'ansi
'ace-jump-mode 'ac-slime 'ac-js2 'ac-emmet)

  ;; Feature mode
  (add-hook 'feature-mode-hook
            (lambda ()
              (local-set-key (kbd "C-s-r") 'jump-to-cucumber-step)))


  ;; Markdown
  (add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))


  ;; Base16-tomorrow theme, and powerline... Bad in NOX though.
  (if (display-graphic-p)
      (progn
        (powerline-center-theme)
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
  (defun c-modes-hook ()
    (flymake-mode)
    (semantic-mode)
    (local-set-key (kbd "s-<f3>") #'semantic-ia-fast-jump)
    (setq ac-sources '(ac-source-semantic
		       ac-source-yasnippet)))
  (add-hook 'c-mode-hook 'c-modes-hook)
  (add-hook 'c++-mode-hook 'c-modes-hook)


  ;; Common Lisp
  ;; Set your lisp system and, optionally, some contribs Common Lisp
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


  ;; Org mode
  (require 'org-install)
  (require 'ob-tangle)
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

       ;; LanguageTool setup
       (require 'langtool))))


  ;; Start global package modes
  (ac-config-default)
  (add-to-list 'ac-modes 'web-mode)


  ;; Enable projectile
  (projectile-global-mode))


;; Load the above hook after the package manager has finished doing its thing
(add-hook 'after-init-hook 'package-config)


;;;; Variables
(setq create-lockfiles nil) ;; Nasty at times


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
