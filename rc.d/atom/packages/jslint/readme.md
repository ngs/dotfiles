# JSLint

> [JSLint](https://github.com/douglascrockford/JSLint) error reports for your [Atom](http://atom.io) editor.

![preview](https://raw.github.com/tcarlsen/atom-jslint/master/preview.png)

## Installation

You can install this plugin via the Packages manager in Atom itself or manually through the terminal

```bash
$ apm install jslint
```

## Usage

JSlint is by default validating on save (this can be changed in the package settings), you can also execute it by hitting `cmd+alt+l` on OS X or `ctrl-alt-l` on Windows and Linux.

If you like you can even set it to validate while typing in the package settings.

## Features

 * Validate on keymap
 * Validate on command
 * Validate on save *(toggle in settings)*
 * Validate on change *(toggle in settings)*
 * Option to hide the error panel if no errors were found *(toggle in settings)*
 * Option to use `fold mode` by default *(toggle in settings)*
 * Supports `.jslintrc` config files *(project located file will overwrite the global file)*

## License

[MIT](http://opensource.org/licenses/MIT) © tcarlsen
