linter = require "./linter"
module.exports =
  config:
    jslintVersion:
      title: "JSLint version:"
      description: "Atom needs a reload for this setting to take effect"
      type: "string"
      default: "latest"
      enum: ["latest", "2014-07-08", "2014-04-21", "2014-02-06", "2014-01-26", "2013-11-23", "2013-09-22", "2013-09-22", "2013-08-26", "2013-08-13", "2013-02-03"]
    validateOnSave:
      title: "Validate on save"
      type: "boolean"
      default: true
    validateOnChange:
      title: "Validate while typing"
      type: "boolean"
      default: false
    hideOnNoErrors:
      title: "Hide panel if no errors was found"
      type: "boolean"
      default: false
    useFoldModeAsDefault:
      title: "Use fold mode as default"
      type: "boolean"
      default: false

  activate: ->
    editor = atom.workspace.getActiveTextEditor()

    atom.commands.add "atom-workspace", "jslint:lint", linter
    atom.config.observe "jslint.validateOnSave", (value) ->
      if value is true
        atom.workspace.eachEditor (editor) ->
          editor.buffer.on "saved", linter
      else
        atom.workspace.eachEditor (editor) ->
          editor.buffer.off "saved", linter

    atom.config.observe "jslint.validateOnChange", (value) ->
      if value is true
        atom.workspace.eachEditor (editor) ->
          editor.buffer.on "contents-modified", linter
      else
        atom.workspace.eachEditor (editor) ->
          editor.buffer.off "contents-modified", linter
