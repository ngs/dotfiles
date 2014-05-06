/*globals module, require, atom*/

var $ = require('atom').$;

module.exports = {
    setFileClasses: function () {
        'use strict';

        atom.workspaceView.on('editor:grammar-changed pane-container:active-pane-item-changed destroyed', function () {
            var editor = atom.workspace.getActiveEditor(),
                language,
                className;

            if (!editor) {
                return;
            }

            language = editor.getGrammar().name;
            className = language.toLowerCase();

            $('.editor:visible').addClass(className);
        });
    }
};
