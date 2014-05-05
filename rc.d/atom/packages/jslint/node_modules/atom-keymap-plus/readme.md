# Atom keymap plus

> An easy way to expand the keymap feature in [Atom](http://atom.io).

## What is this

The idea is to make it easier to use the same keymap for multiple plugins without them overlapping each other.

Keymap plus makes it possible to have the same keymap do different things. This is achieve by adding class names to the editor. That way you can use additional classes when assigning keymaps.

At the moment there is only one class function (`setFileClasses()`), that makes it posible to base your keymap on the active grammar.

## Usage

Heres an example on how to use `setFileClasses()`

Inside your activation
```javascript
var keymap = require('atom-keymap-plus');

module.exports = {
    activate: function () {
        'use strict';

        keymap.setFileClasses();
    }
};
```

Now you are able to make keymaps that a specific to a file type like this
```json
{
    ".editor.javascript": {
        "cmd-alt-l": "jslint"
    },
    ".editor.css": {
        "cmd-alt-l": "csslint"
    }
}
```

## License

[MIT](http://opensource.org/licenses/MIT) © tcarlsen
