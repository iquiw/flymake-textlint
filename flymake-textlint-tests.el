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

(ert-deftest flymake-textlint--parse-buffer-no-rule-found ()
  "Test whether no rule output is parsed as nil."
  (with-temp-buffer
    (insert "
== No rules found, textlint hasn’t done anything ==

Possible reasons:
* Your textlint config file has no rules.
* You have no config file and you aren’t passing rules via command line.
* Your textlint config has a syntax error.

=> How to set up rules?
https://github.com/textlint/textlint/blob/master/docs/configuring.md
")
    (should (not (flymake-textlint--parse-buffer "dummy")))))

(provide 'flymake-textlint-tests)
;;; flymake-textlint-tests.el ends here
