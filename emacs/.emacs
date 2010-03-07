(add-to-list 'load-path "~/.emacs.d")

(server-start)

;(setq viper-mode t)
;(require 'viper)

(load-file "~/.emacs.d/color-theme-colorful-obsolescence.el")
(color-theme-colorful-obsolescence)
;(load-file "~/.emacs.d/color-theme-desert.el")
;(color-theme-desert)

(setq initial-frame-alist
    '((top . 40) (left . 40) (width . 85) (height . 40))
)

(setq inhibit-startup-message t)
(fset 'yes-or-no-p 'y-or-n-p)
(tool-bar-mode -1)
;(global-set-key "\C-w" 'backward-kill-word)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(add-hook 'org-mode-hook 'turn-on-auto-fill)

(require 'org-install)

(org-remember-insinuate)
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))
(add-hook 'remember-mode-hook 'org-remember-apply-template)
(define-key global-map "\C-cr" 'org-remember)

;; mutt stuff: http://upsilon.cc/~zack/blog/posts/2010/02/integrating_Mutt_with_Org-mode/
;; ensure that emacsclient will show just the note to be edited when invoked
;; from Mutt, and that it will shut down emacsclient once finished;
;; fallback to legacy behavior when not invoked via org-protocol.
(add-hook 'org-remember-mode-hook 'delete-other-windows)
(setq my-org-protocol-flag nil)
(defadvice org-remember-finalize (after delete-frame-at-end activate)
  "Delete frame at remember finalization"
  (progn (if my-org-protocol-flag (delete-frame))
         (setq my-org-protocol-flag nil)))
(defadvice org-remember-kill (after delete-frame-at-end activate)
  "Delete frame at remember abort"
  (progn (if my-org-protocol-flag (delete-frame))
         (setq my-org-protocol-flag nil)))
(defadvice org-protocol-remember (before set-org-protocol-flag activate)
  (setq my-org-protocol-flag t))

(setq org-remember-templates
     '(
;      ("Todo" ?t "* TODO %^{Brief Description} %^g\n%?\nAdded: %U" "~/projects/org/gtd.org" "Tasks")
      ("Todo" ?t "* TODO %^{Brief Description} %^g\n%?  Added: %U" "~/projects/org/inbox.org" "Inbox")
      ("Mail" ?m "* %?\n  Source: %u, %c\n  %i" "~/projects/org/inbox.org" "Inbox")
;      ("Private" ?p "\n* %^{topic} %T \n%i%?\n" "C:/charles/gtd/privnotes.org")
;      ("WordofDay" ?w "\n* %^{topic} \n%i%?\n" "C:/charles/gtd/wotd.org")
      ))

(setq org-agenda-exporter-settings
      '((ps-number-of-columns 1)
        (ps-landscape-mode t)
        (htmlize-output-type 'css)))

(setq org-agenda-custom-commands
'(

("c" todo "DONE|DEFERRED|CANCELLED" nil)
("w" todo "WAITING" nil)
("W" agenda "21 days agenda" ((org-agenda-ndays 21)))

("P" "Projects" ((tags "PROJECT")))

("O" "Office and Errands Lists"
     ((agenda)
          (tags-todo "work")
          (tags-todo "@uni")
          (tags-todo "@errands")))

("D" "Daily Action List"
     ((agenda "" ((org-agenda-ndays 1)
                  (org-agenda-sorting-strategy
                     (quote ((agenda time-up priority-down tag-up) )))
                  (org-deadline-warning-days 0)
                 ))))
)
)

(add-hook 'org-agenda-mode-hook 'hl-line-mode)


(defvar org-my-archive-expiry-days 7
  "The number of days after which a completed task should be auto-archived.
This can be 0 for immediate, or a floating point value.")

(defun org-my-archive-done-tasks ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((done-regexp
           (concat "\\* \\(" (regexp-opt org-done-keywords) "\\) "))
          (state-regexp
           (concat "- State \"\\(" (regexp-opt org-done-keywords)
                   "\\)\"\\s-*\\[\\([^]\n]+\\)\\]")))
      (while (re-search-forward done-regexp nil t)
        (let ((end (save-excursion
                     (outline-next-heading)
                     (point)))
              begin)
          (goto-char (line-beginning-position))
          (setq begin (point))
          (if (re-search-forward state-regexp end t)
              (let* ((time-string (match-string 2))
                     (when-closed (org-parse-time-string time-string)))
                (if (>= (time-to-number-of-days
                         (time-subtract (current-time)
                                        (apply #'encode-time when-closed)))
                        org-my-archive-expiry-days)
                    (org-archive-subtree)))
            (goto-char end)))))
    (save-buffer)))

(setq safe-local-variable-values (quote ((after-save-hook archive-done-tasks))))

(defalias 'archive-done-tasks 'org-my-archive-done-tasks)


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(calendar-week-start-day 1)
 '(indent-tabs-mode nil)
 '(org-agenda-files (quote ("~/projects/org/gtd.org")))
 '(org-agenda-repeating-timestamp-show-all nil)
 '(org-agenda-restore-windows-after-quit t)
 '(org-agenda-skip-deadline-if-done t)
 '(org-agenda-skip-scheduled-if-done t)
 '(org-agenda-sorting-strategy (quote ((agenda time-up priority-down tag-up) (todo priority-down tag-up))))
 '(org-agenda-start-on-weekday nil)
 '(org-agenda-todo-ignore-deadlines t)
 '(org-agenda-todo-ignore-scheduled t)
 '(org-agenda-todo-ignore-with-date t)
 '(org-deadline-warning-days 14)
 '(org-default-priority ?C)
 '(org-directory "~/projects/org/")
 '(org-hide-leading-stars t)
 '(org-log-done (quote time))
 '(org-refile-targets (quote (("gtd.org" :maxlevel . 1) ("someday.org" :level . 1))))
 '(org-return-follows-link t)
 '(org-stuck-projects (quote ("+PROJECT/-DONE" ("TODO") nil "")))
 '(org-tags-column -78)
 '(org-use-tag-inheritance nil)
 '(show-paren-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 83 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))

(require 'org)
(require 'org-protocol)

;; add support for "mutt:ID" links
(org-add-link-type "mutt" 'open-mail-in-mutt)

(defun open-mail-in-mutt (message)
  "Open a mail message in Mutt, using an external terminal.

Message can be specified either by a path pointing inside a
Maildir, or by Message-ID."
  (interactive "MPath or Message-ID: ")
  (shell-command
   (format "xterm -e %s %s"
       (substitute-in-file-name "$HOME/bin/mutt-open") message)))

