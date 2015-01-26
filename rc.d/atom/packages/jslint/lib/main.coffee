linter = require "./linter"
module.exports =
  configDefaults:
    validateOnSave: true
    validateOnChange: false
    hideOnNoErrors: false
    useFoldModeAsDefault: false

  activate: ->
    editor = atom.workspace.getActiveTextEditor()

    atom.commands.add "atom-workspace", "jslint:lint", linter
    atom.config.observe "jslint.validateOnSave", (value) ->
      if value is true
        editor.buffer.on "saved", linter
      else
        editor.buffer.off "saved", linter

    atom.config.observe "jslint.validateOnChange", (value) ->
      if value is true
        editor.buffer.on "contents-modified", linter
      else
        editor.buffer.off "contents-modified", linter
