# Flymake-textlint

Flymake backend for [textlint](https://textlint.github.io/).

## Setup

### Install

```console
$ git clone https://github.com/iquiw/flymake-textlint.git
```

### Configuration

```emacs-lisp
(add-to-list 'load-path "path/to/flymake-textlint")
(autoload 'flymake-textlint-setup "flymake-textlint")
(add-hook 'markdown-mode-hook #'flymake-textlint-setup)
```
