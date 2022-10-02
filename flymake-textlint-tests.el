(require 'ert)

(require 'flymake-textlint)

(ert-deftest flymake-textlint--command-line-default ()
  "Test whether default command line is correct."
  (should (equal (flymake-textlint--command-line)
                 '("textlint" "--format" "json" "--stdin"))))

(ert-deftest flymake-textlint--command-line-with-custom-args ()
  "Test whether command line reflects `flymake-textlint-args' setting."
  (let ((flymake-textlint-args '("--config" ".textlintrc")))
    (should (equal (flymake-textlint--command-line)
                   '("textlint" "--config" ".textlintrc" "--format" "json" "--stdin")))))
