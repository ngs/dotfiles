var keymap = require('atom-keymap-plus');
var linter = require('./linter');

module.exports = {
    configDefaults: {
        validateOnSave: true,
        validateOnChange: false,
        hideOnNoErrors: false,
        useFoldModeAsDefault: false
    },
    activate: function () {
        'use strict';

        keymap.setFileClasses();

        atom.workspaceView.command('jslint:lint', linter);

        atom.config.observe('jslint.validateOnSave', {callNow: true}, function (value) {
            if (value === true) {
                atom.workspace.eachEditor(function (editor) {
                    editor.buffer.on('saved', linter);
                });
            } else {
                atom.workspace.eachEditor(function (editor) {
                    editor.buffer.off('saved', linter);
                });
            }
        });

        atom.config.observe('jslint.validateOnChange', {callNow: true}, function (value) {
            if (value === true) {
                atom.workspace.eachEditor(function (editor) {
                    editor.buffer.on('contents-modified', linter);
                });
            } else {
                atom.workspace.eachEditor(function (editor) {
                    editor.buffer.off('contents-modified', linter);
                });
            }
        });
    }
};
