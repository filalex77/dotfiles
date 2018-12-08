;;; private/default/config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-peacock)

(setq doom-font (font-spec :family "DejaVu Sans Mono" :size 13)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans Mono")
      doom-unicode-font (font-spec :family "DejaVu Sans Mono")
      doom-big-font (font-spec :family "DejaVu Sans Mono" :size 19))

(map! :n "Q" #'fill-paragraph
      "M-E" #'kill-this-buffer)

(map! :prefix "g" :n "X" #'evil-exchange-cancel)

(setq doom-localleader-key ",")

(map! :leader
      :desc "Toggle treemacs" :n "F" #'treemacs
      (:desc "open" :prefix "o"
        (:when (featurep! :tools password-store)
          :desc "Open password-store" :n "s"
          (cond
           ((featurep! :completion helm) #'helm-pass)
           ((featurep! :completion ivy) #'+pass/ivy)
           (t #'pass)))
        :desc "Open elfeed" :n "f" #'elfeed
        :desc "Calculator" :n "c" #'calc
        :desc "Calendar" :n "C" #'calendar
        :desc "URL" :n "U" #'browse-url
        (:desc "Org file" :prefix "o"
          :desc "Inbox" :n "i" (λ! (+private/open-gtd-file "inbox"))
          :desc "Projects" :n "p" (λ! (+private/open-gtd-file "gtd"))))
      (:desc "file" :prefix "f"
        :desc "Transfer a file" :n "t" #'+private/transfer-file
        :desc "Transfer this file" :n "T" #'+private/transfer-this-file
        :desc "Config file" :n "c" #'+private/find-config-file
        :desc "Private module" :n "p"
        (λ!
         (let ((default-directory (s-join "" `(,doom-modules-dir "private/default"))))
           (call-interactively 'find-file)))
        :desc "Gentoo (Portage) conf" :n "g"
        (defhydra hydra-edit-portage (:color blue)
          "Edit Portage conf files."
          ("c" (find-file "/sudo::/etc/portage/make.conf") "make.conf")
          ("k" (find-file "/sudo::/etc/portage/package.accept_keywords") "package.accept_keywords")
          ("l" (find-file "/sudo::/etc/portage/package.license") "package.license")
          ("m" (find-file "/sudo::/etc/portage/package.mask") "package.mask")
          ("p" (find-file "/sudo::/etc/portage/make.profile") "make.profile")
          ("u" (find-file "/sudo::/etc/portage/package.use") "package.use")))
      (:desc "window" :prefix "w"
        :n "z" #'doom/window-zoom
        :n "x" #'kill-buffer-and-window)
      (:desc "Movement" :n "M"
        (defhydra hydra-movement (:color pink :hint nil)
          "
                  Move around quickly (_q_uit)

                  _d_ / _u_             scroll up/down half a page
                  _b_, _S-SPC_ / _f_, _SPC_ scroll up/down a page
                  "
          ("d" evil-scroll-down "down")
          ("u" evil-scroll-up "up")
          ("b" evil-scroll-page-up "page up")
          ("S-SPC" evil-scroll-page-up "page up")
          ("f" evil-scroll-page-down "page down")
          ("SPC" evil-scroll-page-down "page down")
          ("q" nil "quit"))))

(defun +private/elfeed-set-search-filter (&optional filter)
  (setq elfeed-search-filter (format "@2-week-ago -ignore %s" (or filter "")))
  (elfeed-search-update :force))

(map! (:after elfeed
        :map (elfeed-search-mode-map elfeed-show-mode-map)
        (:desc "Filter" :prefix "f"
          :desc "None"   :n "f" (λ! (+private/elfeed-set-search-filter))
          :desc "Games"  :n "g" (λ! (+private/elfeed-set-search-filter "+linux +games"))
          :desc "Linux"  :n "l" (λ! (+private/elfeed-set-search-filter "+linux -reddit"))
          :desc "Videos" :n "v" (λ! (+private/elfeed-set-search-filter "+video")))))

(map! (:after elfeed
        :map elfeed-search-mode-map
        :n "r" #'elfeed-search-fetch-visible
        :n "R" #'elfeed-search-fetch))

(map! (:after elfeed
        :map (elfeed-search-mode-map elfeed-show-mode-map)
        :n "o" #'elfeed-search-browse-url))

(map! (:after org
        :map org-mode-map
        (:after org-agenda
          :map org-agenda-mode-map
          ;; Movement
          :m "j"     #'org-agenda-next-item
          :m "k"     #'org-agenda-previous-item
          :m "n"     #'org-agenda-later
          :m "p"     #'org-agenda-earlier
          :m "TAB"   #'org-agenda-goto
          :m "."     #'org-agenda-goto-today
          :m "g c"   #'org-agenda-goto-calendar

          ;; Display
          :m "v c"   #'org-agenda-columns
          :m "v d"   #'org-agenda-day-view
          :m "v w"   #'org-agenda-week-view
          :m "v m"   #'org-agenda-month-view
          :m "v y"   #'org-agenda-year-view
          :m "v SPC" #'org-agenda-reset-view
          :m "v a"   #'org-agenda-archives-mode
          :m "F"     #'org-agenda-follow-mode
          :m "l"     #'org-agenda-log-mode
          :m "b"     #'org-agenda-redo
          :m "v g"   #'org-agenda-toggle-time-grid

          ;; Filtering
          :m "/"     #'org-agenda-filter-by-tag
          :m "<"     #'org-agenda-filter-by-category
          :m "^"     #'org-agenda-filter-by-top-headline
          :m "="     #'org-agenda-filter-by-regexp
          :m "_"     #'org-agenda-filter-by-effort
          :m "|"     #'org-agenda-filter-remove-all
          :m "T"     #'org-agenda-show-tags

          ;; Actions
          :m "S"     #'org-save-all-org-buffers
          :m "t"     #'org-agenda-todo
          :m "L"     #'org-agenda-todo-nextset
          :m "H"     #'org-agenda-todo-previousset
          :m "u"     #'org-agenda-undo
          :m "D"     #'org-agenda-kill
          :m "C"     #'org-agenda-capture
          :m "R"     #'org-agenda-refile

          ;; Dates
          :m "d d"   #'org-agenda-deadline
          :m "d s"   #'org-agenda-schedule
          :m "d c"   #'org-agenda-date-prompt
          :m "c i"   #'org-agenda-clock-in
          :m "c o"   #'org-agenda-clock-out
          :m "c X"   #'org-agenda-clock-cancel)))

(map! (:after org
        :map org-mode-map
        :localleader
        :n "RET" #'org-ctrl-c-ret
        :n "," #'org-ctrl-c-ctrl-c
        :n "*" #'org-ctrl-c-star
        :n "^" #'org-sort
        :n "." #'org-sparse-tree
        :n "o" #'+private/org-extract-link
        :desc "Archive subtree"  :n "a" #'org-archive-subtree-default-with-confirmation
        :desc "Open org archive" :n "A" (λ! (find-file (org-extract-archive-file)))
        :n "d" #'org-deadline
        :n "s" #'org-schedule
        :n "<" #'org-time-stamp
        :n "[" #'org-time-stamp-inactive
        :n "C" #'org-capture
        :n "X" #'org-capture
        :n "R" #'org-refile
        :n "t" #'org-todo
        :n ":" #'org-set-tags
        :n "e" #'org-export-dispatch
        :n "E" #'org-edit-special
        :desc "Tree to indirect buffer" :n "B" #'org-tree-to-indirect-buffer
        (:desc "Babel" :prefix "b"
           :n "a" #'org-babel-sha1-hash
           :n "b" #'org-babel-execute-buffer
           :n "c" #'org-babel-check-src-block
           :n "d" #'org-babel-demarcate-block
           :n "e" #'org-babel-execute-maybe
           :n "f" #'org-babel-tangle-file
           :n "g" #'org-babel-goto-named-src-block
           :n "h" #'org-babel-describe-bindings
           :n "i" #'org-babel-lob-ingest
           :n "j" #'org-babel-insert-header-arg
           :n "k" #'org-babel-remove-result-one-or-many
           :n "l" #'org-babel-load-in-session
           :n "n" #'org-babel-next-src-block
           :n "o" #'org-babel-open-src-block-result
           :n "p" #'org-babel-previous-src-block
           :n "r" #'org-babel-goto-named-result
           :n "s" #'org-babel-execute-subtree
           :n "t" #'org-babel-tangle
           :n "u" #'org-babel-goto-src-block-head
           :n "v" #'org-babel-expand-src-block
           :n "x" #'org-babel-do-key-sequence-in-edit-buffer
           :n "z" #'org-babel-switch-to-session-with-code)
        (:desc "text" :prefix "x"
          :desc "bold" :n "b" (λ! (org-emphasize ?*))
          :desc "code" :n "c" (λ! (org-emphasize ?~))
          :desc "italic" :n "i" (λ! (org-emphasize ?/))
          :desc "clear" :n "r" (λ! (org-emphasize ?\ ))
          :desc "strike-through" :n "s" (λ! (org-emphasize ?+))
          :desc "underline" :n "u" (λ! (org-emphasize ?_))
          :desc "verbose" :n "v" (λ! (org-emphasize ?=)))
        (:desc "clock" :prefix "c"
          :n "c" #'org-clock-in
          :n "C" #'org-clock-out
          :n "i" #'org-clock-in
          :n "o" #'org-clock-out
          :n "g" #'org-clock-goto
          :desc "org-clock-goto-select" :n "G" (λ! (org-clock-goto 'select))
          :n "x" #'org-clock-cancel)
        :desc "Move around in Org" :n "M"
        (defhydra hydra-org-movement (:color pink :hint nil)
          "
  Org-mode movement (_q_uit)

  _h_/_j_/_k_/_l_/_n_/_p_ move around headlines
  _H_/_J_/_K_/_L_     move headlines around
  "
          ("h" org-up-element nil)
          ("j" outline-forward-same-level nil)
          ("k" outline-backward-same-level nil)
          ("l" org-down-element nil)
          ("H" org-promote-subtree nil)
          ("J" org-metadown nil)
          ("K" org-metaup nil)
          ("L" org-demote-subtree nil)
          ("n" org-forward-paragraph nil)
          ("p" org-backward-paragraph nil)
          ("q" nil nil))))

(map! :map org-mode-map
      :localleader
      (:after org-src
        :map org-src-mode-map
        :desc "Exit" :n doom-localleader-key #'org-edit-src-exit
        :desc "Abort" :n "k" #'org-edit-src-abort
        :desc "Save" :n "s" #'org-edit-src-save))

(map! (:after tex
        :map TeX-mode-map
        :localleader
        :desc "Run a command"
        :n doom-localleader-key #'TeX-command-master
        :desc "View"
        :n "v" #'TeX-view
        :desc "Build"
        :n "b" (λ! (save-buffer)
                   (TeX-command-menu "LaTeX"))
        :n "e" #'LaTeX-environment))

(map! (:after parinfer
        :map parinfer-mode-map
        :localleader
        :desc "Toggle parinfer" :n "m" #'parinfer-toggle-mode))

(map! (:after company
        :map company-active-map
        "C-l" #'company-complete-selection))

(require 'treemacs)

(map! (:after treemacs
        :leader
        :n "-" #'+private/treemacs-back-and-forth))

(setq user-full-name "Oleksii Filonenko"
      user-mail-address "brightone@protonmail.com")

(setq-default fill-column 79)

(require 'org)

(setq org-directory "~/org/"
      org-gtd-directory (concat org-directory "gtd/")
      org-default-notes-file (concat org-gtd-directory "gtd.org")
      org-agenda-files (--map (concat org-gtd-directory it ".org")
                              '("inbox" "gtd" "tickler"))
      org-agenda-span 'week
      org-agenda-include-diary t
      org-agenda-custom-commands
      (--map
       (let* ((key (substring it 0 1))
              (desc (format "Tasks @ %s" (s-titleize it)))
              (at-tag (s-prepend "@" it))
              (header `((org-agenda-overriding-header ,(s-append ":" desc)))))
         `(,key ,desc tags-todo ,at-tag ,header))
       '("home" "uni" "work"))
      org-ellipsis "|>"
      org-blank-before-new-entry '((heading . nil)
                                   (plain-list-item . nil))
      org-todo-keywords '((sequence "TODO(t)" "WAITING(w)" "|" "CANCELLED(c@)" "DONE(d!)"))
      org-capture-templates '(("t" "Todo" entry (file+headline "gtd/inbox.org" "Inbox") "* TODO %i%?")
                              ("T" "Tickler" entry (file+headline "gtd/tickler.org" "Tickler") "* %i%?\n %U")
                              ("n" "Note" entry (file+headline "Notes.org" "Notes") "* %i%?\n %u"))
      org-refile-targets '((nil :maxlevel . 2)
                           (org-agenda-files :maxlevel . 2)
                           ("someday.org" :maxlevel . 2))
      org-link-abbrev-alist '(("r" . "https://reddit.com/r/")
                              ("gh" . "https://github.com/")
                              ("yt" . "https://youtube.com/watch?v=")
                              ("aw" . "https://wiki.archlinux.org/index.php?search=")
                              ("gw" . "https://wiki.gentoo.org/index.php?search="))
      org-global-properties '(("Effort_ALL" . "1:00 2:00 3:00 4:00 5:00 0:15 0:30 10:00 20:00 40:00")
                              ("COOKIE_DATA" . "recursive"))
      org-columns-default-format "%TODO(State) %50ITEM(Task) %10Effort{:} %10CLOCKSUM(Clocked)")

(add-to-list 'org-modules 'habits)
(setq org-habit-graph-column 60)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(mapc (lambda (x)
        (add-hook x (λ! (org-update-statistics-cookies t))))
      '(org-after-refile-insert-hook org-capture-after-finalize-hook))

(setq +private/reveal-js-version "3.7.0"
      org-reveal-root (format "file:///home/%s/org/.assets/reveal.js-%s"
                              user-login-name +private/reveal-js-version)
      org-reveal-theme "black"
      org-reveal-transition "none"
      org-reveal-title-slide "<h2>%t</h2>"
      org-reveal-default-frag-style "appear"
      org-export-with-section-numbers nil
      org-export-with-toc nil
      org-export-with-todo-keywords nil
      org-export-time-stamp-file nil)

(require 'eshell)

(setq eshell-visual-commands '(("htop") ("top") ("git" "log" "diff" "show")))

(require 'which-key)

(setq which-key-idle-delay 0.5)

(require 'company)

(require 'company-template)

(setq company-idle-delay 0.2)

(setq company-minimum-prefix-length 2)

(require 'magit)

(setq magit-repository-directories '(("~/dev/" . 4)
                                     ("~/Documents/" . 2)
                                     ("~/.dotfiles" . 0)))

(add-hook 'git-commit-mode-hook 'evil-insert-state)

(require 'latex)

(setq org-latex-packages-alist '(("AUTO" "babel" t)
                                 ("T2A" "fontenc" t)))

(setq +private/open-link-with-commands '(copy eww mpv qutebrowser-client))

(setq +private/open-link-with-qualities '("240" "360" "480" "720" "1080"))

(setq browse-url-browser-function
      (lambda (url new-window)
        (interactive)
        (+private/open-link-with url)))

(require 'elfeed)

(setq elfeed-search-filter "@2-week-ago -ignore")

(require 'elfeed-org)
(elfeed-org)

(setq rmh-elfeed-org-files (list (concat org-directory "elfeed.org")))

(require 'evil-snipe)

(dolist (hook '(calc-mode-hook magit-mode-hook))
  (dolist (it '(turn-off-evil-snipe-mode turn-off-evil-snipe-override-mode))
    (add-hook hook it)))

(setq evil-snipe-tab-increment t)

(setq evil-snipe-override-evil-repeat-keys nil)

(setq web-mode-auto-close-style 1)
