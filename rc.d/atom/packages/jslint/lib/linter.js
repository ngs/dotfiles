var JSLINT = require('jslint').load('latest');
var msgPanel = require('atom-message-panel');
var config = require('./config');

module.exports = function () {
    'use strict';

    var editor = atom.workspace.getActiveEditor(),
        content,
        data,
        error,
        lines = [],
        i;

    if (!editor) {
        return;
    }

    if (editor.getGrammar().name === 'JavaScript') {
        content = editor.getText();

        JSLINT(content, config.load());

        data = JSLINT.data();

        if (atom.workspaceView.find('.am-panel').length !== 1) {
            msgPanel.init('<span class="icon-bug"></span> JSLint report');

            atom.config.observe('jslint.useFoldModeAsDefault', {callNow: true}, function (value) {
                if (value === true) {
                    msgPanel.fold(0);
                }
            });
        } else {
            msgPanel.clear();
        }

        if (data.errors.length === 0) {
            atom.config.observe('jslint.hideOnNoErrors', {callNow: true}, function (value) {
                if (value === true) {
                    msgPanel.destroy();
                } else {
                    msgPanel.append.header('√ No errors were found!', 'text-success');
                }
            });
        } else {
            for (i = 0; i < data.errors.length; i += 1) {
                error = data.errors[i];

                if (error) {
                    if (error.code) {
                        error.reason = error.reason.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                        error.evidence = error.evidence.trim();
                        lines.push(error.line);

                        msgPanel.append.lineMessage(error.line, error.character, error.reason, error.evidence, 'text-error');
                    } else {
                        msgPanel.append.message(String(error.reason), 'text-info');
                    }
                }
            }
        }

        msgPanel.append.lineIndicators(lines, 'text-error');

        atom.workspaceView.on('pane-container:active-pane-item-changed destroyed', function () {
            msgPanel.destroy();
        });
    }
};
