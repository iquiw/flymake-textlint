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

(ert-deftest flymake-textlint--parse-buffer-1-error ()
  "Test whether 1 error output can be parsed."
  (with-temp-buffer
    (insert "[{\"messages\":[{\"type\":\"lint\",\"ruleId\":\"jtf-style/2.2.1.ひらがなと漢字の使い分け\",\"message\":\"又は => または\",\"index\":59,\"line\":3,\"column\":2,\"range\":[59,60],\"loc\":{\"start\":{\"line\":3,\"column\":2},\"end\":{\"line\":3,\"column\":3}},\"severity\":2,\"fix\":{\"range\":[59,61],\"text\":\"または\"}}],\"filePath\":\"/tmp/test.md\"}]
")
    (let ((diags (flymake-textlint--parse-buffer "dummy")))
      (should (equal (length diags) 1))
      (let ((diag (elt diags 0)))
        (should (equal (flymake--diag-beg diag) 60))
        (should (equal (flymake--diag-end diag) 61))
        (should (equal (flymake--diag-type diag) :error))
        (should (equal (flymake--diag-text diag) "jtf-style/2.2.1.ひらがなと漢字の使い分け: 又は => または"))))))

(ert-deftest flymake-textlint--parse-buffer-2-error ()
  "Test whether 2 errors output can be parsed."
  (with-temp-buffer
    (insert "[{\"messages\":[{\"type\":\"lint\",\"ruleId\":\"jtf-style/1.1.1.本文\",\"message\":\"本文を敬体(ですます調)に統一して下さい。\\n本文の文体は、敬体(ですます調)あるいは常体(である調)のどちらかで統一します。\\n\\\"である。\\\"が常体(である調)です。\",\"index\":66,\"line\":3,\"column\":9,\"range\":[66,67],\"loc\":{\"start\":{\"line\":3,\"column\":9},\"end\":{\"line\":3,\"column\":10}},\"severity\":2},{\"type\":\"lint\",\"ruleId\":\"jtf-style/2.2.1.ひらがなと漢字の使い分け\",\"message\":\"又は => または\",\"index\":73,\"line\":5,\"column\":2,\"range\":[73,74],\"loc\":{\"start\":{\"line\":5,\"column\":2},\"end\":{\"line\":5,\"column\":3}},\"severity\":2,\"fix\":{\"range\":[73,75],\"text\":\"または\"}}],\"filePath\":\"/tmp/test.md\"}]
")
    (let ((diags (flymake-textlint--parse-buffer "dummy")))
      (should (equal (length diags) 2))
      (let ((diag1 (elt diags 0))
            (diag2 (elt diags 1)))
        (should (equal (flymake--diag-beg diag1) 67))
        (should (equal (flymake--diag-end diag1) 68))
        (should (equal (flymake--diag-type diag1) :error))
        (should (equal (flymake--diag-text diag1) "jtf-style/1.1.1.本文: 本文を敬体(ですます調)に統一して下さい。\n本文の文体は、敬体(ですます調)あるいは常体(である調)のどちらかで統一します。\n\"である。\"が常体(である調)です。"))
        (should (equal (flymake--diag-beg diag2) 74))
        (should (equal (flymake--diag-end diag2) 75))
        (should (equal (flymake--diag-type diag2) :error))
        (should (equal (flymake--diag-text diag2) "jtf-style/2.2.1.ひらがなと漢字の使い分け: 又は => または"))
        ))))

(provide 'flymake-textlint-tests)
;;; flymake-textlint-tests.el ends here
