(require 'ert)

(require 'flymake-textlint)

(ert-deftest flymake-textlint--command-line-default ()
  "Test whether default command line is correct."
  (should (equal (flymake-textlint--command-line)
                 '("textlint" "--format" "json" "--stdin"))))
