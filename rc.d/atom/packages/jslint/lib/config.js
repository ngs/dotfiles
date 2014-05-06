/*jslint stupid: true*/

var path = require('path');
var fs = require('fs');

module.exports = {
    load: function () {
        'use strict';

        var defaultConfigPath = path.normalize(path.join(process.env.HOME, '.jslintrc')),
            projectConfigPath = path.normalize(path.join(atom.project.getPath(), '.jslintrc')),
            config = {};

        try {
            config = JSON.parse(fs.readFileSync(defaultConfigPath, 'utf-8'));
        } catch (err) {
            if (defaultConfigPath && err.code !== 'ENOENT') {
                console.log('Error reading config file "' + defaultConfigPath + '": ' + err);
            }
        }

        try {
            config = JSON.parse(fs.readFileSync(projectConfigPath, 'utf-8'));
        } catch (err) {
            if (projectConfigPath && err.code !== 'ENOENT') {
                console.log('Error reading config file "' + projectConfigPath + '": ' + err);
            }
        }

        return config;
    }
};
