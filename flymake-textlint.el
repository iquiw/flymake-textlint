;;; flymake-textlint.el --- Flymake backend for textlint  -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Iku Iwasa

;; Author: Iku Iwasa <iku.iwasa@gmail.com>
;; Version: 0.0.1
;; Keywords: languages tools
;; Package-Requires: ((emacs "27.1"))
;; Homepage: https://github.com/iquiw/flymake-textlint


;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Flymake backend for textlint.
;;

;;; Code:
(require 'flymake)

(defgroup flymake-textlint nil
  "Flymake backend for textlint."
  :group 'flymake
  :prefix "flymake-textlint-")

(defcustom flymake-textlint-program "textlint"
  "Program to execute \"textlint\"."
  :type 'string)

(defcustom flymake-textlint-args '()
  "Arguments of \"textlint\" program."
  :type '(string))

(defvar-local flymake-textlint--proc nil)

(defun flymake-textlint--command-line ()
  "Generate command list of \"textlint\" to be executed."
  `(,flymake-textlint-program
    ,@flymake-textlint-args
    "--format" "json" "--stdin"
    ,@(let ((name (buffer-file-name)))
        (and name (list "--stdin-filename" name)))))

(defun flymake-textlint--parse-buffer (source)
  "Parse \"textlint\" output buffer.
SOURCE is used for `flymake-make-diagnostic', not a buffer to be parsed."
  (goto-char (point-min))
  (if (re-search-forward "^== No rules found" 100 t)
      (progn
        (flymake-log :error "No textlint rule found")
        nil)
    (let ((json (json-parse-buffer)))
      (mapcar
       (lambda (message)
         (let ((range (gethash "range" message)))
           (flymake-make-diagnostic
            source
            (+ (elt range 0) 1)
            (+ (elt range 1) 1)
            (flymake-textlint--severity (gethash "severity" message))
            (format "%s: %s"
                    (gethash "ruleId" message)
                    (gethash "message" message)))))
       (gethash "messages" (elt json 0))))))

(defun flymake-textlint--severity (level)
  "Convert numerical severity LEVEL to Flymake severity type."
  (cond
   ((= level 0) :note)
   ((= level 1) :warning)
   ((= level 2) :error)
   (t (flymake-log :warning "Unknown severity level %s" level)
      :note)))

(defun flymake-textlint (report-fn &rest _args)
  "Backend function to process \"textlint\".
JSON output of \"textlint\" is processed and passed to REPORT-FN."
  ;; Not having textlint command is a serious problem which should cause
  ;; the backend to disable itself, so an error is signaled.
  ;;
  (unless (executable-find "textlint")
    (error "Cannot find a suitable textlint"))
  ;; If a live process launched in an earlier check was found, that
  ;; process is killed.  When that process's sentinel eventually runs,
  ;; it will notice its obsoletion, since it have since reset
  ;; `flymake-textlint--proc' to a different value
  ;;
  (when (process-live-p flymake-textlint--proc)
    (kill-process flymake-textlint--proc))

  ;; Save the current buffer, the narrowing restriction, remove any
  ;; narrowing restriction.
  ;;
  (let ((source (current-buffer)))
    (save-restriction
      (widen)
      ;; Reset the `flymake-textlint--proc' process to a new process
      ;; calling the textlint tool.
      ;;
      (setq
       flymake-textlint--proc
       (make-process
        :name "flymake-textlint" :noquery t :connection-type 'pipe
        ;; Make output go to a temporary buffer.
        ;;
        :buffer (generate-new-buffer " *flymake-textlint*")
        :command (flymake-textlint--command-line)
        :sentinel
        (lambda (proc _event)
          ;; Check that the process has indeed exited, as it might
          ;; be simply suspended.
          ;;
          (when (memq (process-status proc) '(exit signal))
            (unwind-protect
                ;; Only proceed if `proc' is the same as
                ;; `flymake-textlint--proc', which indicates that
                ;; `proc' is not an obsolete process.
                ;;
                (if (with-current-buffer source (eq proc flymake-textlint--proc))
                    (with-current-buffer (process-buffer proc)
                      (funcall report-fn (flymake-textlint--parse-buffer source)))
                  (flymake-log :warning "Canceling obsolete check %s"
                               proc))
              ;; Cleanup the temporary buffer used to hold the
              ;; check's output.
              ;;
              (kill-buffer (process-buffer proc)))))))
      ;; Send the buffer contents to the process's stdin, followed by
      ;; an EOF.
      ;;
      (process-send-region flymake-textlint--proc (point-min) (point-max))
      (process-send-eof flymake-textlint--proc))))

;;;###autoload
(defun flymake-textlint-setup ()
  "Add `flymake-textlint' to `flymake-diagnostic-functions' locally."
  (add-hook 'flymake-diagnostic-functions 'flymake-textlint nil t))

(provide 'flymake-textlint)
;;; flymake-textlint.el ends here
