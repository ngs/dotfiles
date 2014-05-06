{View, $$$} = require 'atom'
{exec} = require 'child_process'

module.exports =
class GruntHelperView extends View

  @content: ->
    @div class: 'grunt-helper tool-panel panel-bottom', =>
      @div class: 'panel-body padded', =>
        @ul outlet: 'resultList', class: 'list-group'

  initialize: (serializeState) ->
    atom.workspaceView.command "grunt-helper:run-default", => @runDefault()
    atom.workspaceView.command "grunt-helper:run-custom", => @runCustom()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  runCustom: ->
    if @hasParent()
      @detach()
    else
      messages = ["Not implemented yet", "Sorry"]
      @resultList.empty()
      console.log messages
      for message in messages
        @resultList.append $$$ ->
          @li class: 'list-item', =>
            @span "#{message}"
      atom.workspaceView.prependToBottom this

  runDefault: =>
    if @hasParent()
      @detach()
    else
      exec "grunt --no-color", cwd: atom.project.path, (stdin, stdout, error) =>
        if error
          messages = error.split '\n'
        else
          messages = stdout.split '\n'
        @resultList.empty()
        console.log messages
        for message in messages
          @resultList.append $$$ ->
            @li class: 'list-item', =>
              @span "#{message}"
        atom.workspaceView.prependToBottom this
