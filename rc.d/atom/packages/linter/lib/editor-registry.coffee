{Emitter, CompositeDisposable} = require('atom')
EditorLinter = require('./editor-linter')

class EditorRegistry
  constructor: ->
    @emitter = new Emitter
    @subscriptions = new CompositeDisposable
    @editorLinters = new Map()

  create: (textEditor) ->
    @editorLinters.set(textEditor, editorLinter = new EditorLinter(textEditor))
    editorLinter.onDidDestroy =>
      @editorLinters.delete(textEditor)
      editorLinter.deactivate()
    @emitter.emit('observe', editorLinter)
    return editorLinter

  forEach: (callback) ->
    @editorLinters.forEach(callback)

  ofTextEditor: (editor) ->
    return @editorLinters.get(editor)

  ofActiveTextEditor: ->
    return @ofTextEditor(atom.workspace.getActiveTextEditor())

  observe: (callback) ->
    @forEach(callback)
    @emitter.on('observe', callback)

  deactivate: ->
    @emitter.dispose()
    @subscriptions.dispose()
    @editorLinters.forEach (editorLinter) ->
      editorLinter.deactivate()
    @editorLinters.clear()

module.exports = EditorRegistry
