# Flymake-textlint

Flymake backend for [textlint](https://textlint.github.io/).

## Prerequisite

### Runtime dependencies

[textlint](https://textlint.github.io/) CLI

Install it globally.

```console
$ npm install -g textlint
```

With [some rules](https://github.com/textlint-ja/textlint-rule-preset-JTF-style). e.g.

```console
$ npm install -g textlint-rule-preset-jtf-style
```

And prepare `.textlintrc`. e.g.

```json
{
  "rules": {
    "preset-jtf-style": {
      "2.1.2.漢字": true,
      "2.1.5.カタカナ": true,
      "2.1.6.カタカナの長音": true,
      "2.2.1.ひらがなと漢字の使い分け": true
    }
  }
}
```

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

## License

Licensed under the GPL 3+.
