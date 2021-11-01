;;; lsp-ng.el --- description -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Sidharth Arya

;; Author: Sidharth Arya <sidhartharya10@gmail.com>
;; Maintainer: Sidharth Arya <sidhartharya10@gmail.com>
;; Created: 01 Nov 2021
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1") (exec-path-from-shell "20210914.1247"))
;; Keywords: lisp tools languages
;; URL: https://github.com/SidharthArya/lsp-ng

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; LSP Clients for the Angular JS.

;;; Code:

(require 'lsp-mode)
(require 'exec-path-from-shell)

(defgroup lsp-ng nil
  "Support for AngularJS."
  :group 'lsp-mode)

(defcustom lsp-ng-find-path "/usr/bin"
  "Path to search  node and npm in.")


(defcustom lsp-ng-global-path nil
  "Global path to search for npm packages.")

(lsp-dependency 'ng-langserver
                '(:system (concat lsp-ng-find-path "/bin/node")
                '(:npm :package "@angular/language-server"
                       :path (concat
                              lsp-ng-global-path
                              "/lib/node_modules/@angular/language-server/bin/ngserver")))

                  
(defcustom lsp-clients-ng-language-server-command
  '("/home/arya/.nvm/versions/node/v14.18.1/bin/node"
    "/home/arya/.config/yarn/global/node_modules/@angular/language-server"
    ;; "--ngProbeLocations"
    ;; "/home/arya/.config/yarn/global/node_modules"
    ;; "--tsProbeLocations"
    ;; "/home/arya/.config/yarn/global/node_modules"
    "--stdio")
  "Language Server Command to execute")

(defun lsp-ng-init()
  "Initialize Angular"
  (exec-path-from-shell-initialize)
  (add-to-list 'exec-path lsp-ng-find-path)
  (setenv (concat (getenv "PATH") ":" lsp-ng-find-path))
  (setq lsp-ng-global-path (string-trim
                            (shell-command-to-string
                             (concat
                              lsp-ng-find-path
                              "/node" " "
                              lsp-ng-find-path
                              "/npm" " "
                              "config get prefix"))))
  )

(defun lsp-ng-activate-p (filename &optional _)
  "Check if the javascript-typescript language server should be enabled based on FILENAME."
  (or (string-match-p "\\.json\\|\\.html\\|\\.mjs\\|\\.[jt]sx?\\'" filename)
      (and (derived-mode-p 'js-mode 'typescript-mode)
           (not (derived-mode-p 'json-mode)))))
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection
                                   (-const lsp-clients-ng-language-server-command))
                  :activation-fn 'lsp-ng-activate-p
                  :add-on? t
                  :priority -3
                  :download-server-fn (lambda (_client callback error-callback _update?)
                                        (lsp-package-ensure
                                         'ng-langserver
                                         callback
                                         error-callback))
                  :server-id 'angular-ls))
(defcustom lsp-clients-ng-server-args '()
  "Extra arguments for the typescript-language-server language server."
  :group 'lsp-ng
  :risky t
  :type '(repeat string))


(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection (lambda ()
                                                          (cons (lsp-package-path 'javascript-typescript-langserver)
                                                                lsp-clients-typescript-javascript-server-args)))
                  :activation-fn 'lsp-typescript-javascript-tsx-jsx-activate-p
                  :priority -3
                  :completion-in-comments? t
                  :server-id 'jsts-ls
                  :download-server-fn (lambda (_client callback error-callback _update?)
                                        (lsp-package-ensure
                                         'javascript-typescript-langserver
                                         callback
                                         error-callback))))




(lsp-consistency-check lsp-ng)

(provide 'lsp-ng)
;;; lsp-ng.el ends here
