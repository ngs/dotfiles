{$, View, TextEditorView} = require 'atom-space-pen-views'
Utils = require './utils'

module.exports =
class RunCommandView extends View
  @content: ->
    @div class: 'command-entry', =>
      @subview 'commandEntryView', new TextEditorView
        mini: true,
        placeholderText: 'rake spec'

  initialize: (runner) ->
    @panel = atom.workspace.addModalPanel
      item: @,
      visible: false

    @runner = runner
    @subscriptions = atom.commands.add @element,
      'core:confirm': (event) =>
        @confirm()
        event.stopPropagation()
      'core:cancel': (event) =>
        @cancel()
        event.stopPropagation()

    @commandEntryView.on 'blur', =>
      @cancel()

  destroy: ->
    @subscriptions.destroy()

  show: ->
    @panel.show()

    @storeFocusedElement()
    @commandEntryView.focus()

    editor = @commandEntryView.getModel()
    editor.setSelectedBufferRange editor.getBuffer().getRange()

  hide: ->
    @panel.hide()

  isVisible: ->
    @panel.isVisible()



  getCommand: ->
    command = @commandEntryView.getModel().getText()
    if(!Utils.stringIsBlank(command))
      command

  cancel: ->
    @restoreFocusedElement()
    @hide()

  confirm: ->
    if(@getCommand())
      @runner.run(@getCommand())

    @cancel()

  storeFocusedElement: ->
    @previouslyFocused = $(document.activeElement)

  restoreFocusedElement: ->
    @previouslyFocused?.focus?()
