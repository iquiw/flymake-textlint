;;; flymake-textlint-tests.el --- Tests for flymake-textlint  -*- lexical-binding: t; -*-

;;; Code:
(require 'ert)

(require 'flymake-textlint)

(ert-deftest flymake-textlint--command-line-default ()
  "Test whether default command line is correct."
  (let ((buffer-file-name nil))
    (should (equal (flymake-textlint--command-line)
                   '("textlint" "--format" "json" "--stdin")))))

(ert-deftest flymake-textlint--command-line-with-custom-args ()
  "Test whether command line reflects `flymake-textlint-args' setting."
  (let ((flymake-textlint-args '("--config" ".textlintrc"))
        (buffer-file-name nil))
    (should (equal (flymake-textlint--command-line)
                   '("textlint" "--config" ".textlintrc" "--format" "json" "--stdin")))))

(ert-deftest flymake-textlint--command-line-with-name ()
  "Test whether default command line is correct."
  (let ((buffer-file-name "test.md"))
    (should (equal (flymake-textlint--command-line)
                   '("textlint" "--format" "json" "--stdin" "--stdin-filename" "test.md")))))

(provide 'flymake-textlint-tests)
;;; flymake-textlint-tests.el ends here
