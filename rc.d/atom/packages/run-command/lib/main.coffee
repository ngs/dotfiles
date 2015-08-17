{ContentDisposable} = require 'atom'
CommandRunner = require './command-runner'
RunCommandView = require './run-command-view'
CommandOutputView = require './command-output-view'

module.exports =
  config:
    shellCommand:
      type: 'string'
      default: '/bin/bash'
    useLoginShell:
      type: 'boolean'
      default: true

  activate: (state) ->
    @runner = new CommandRunner()

    @commandOutputView = new CommandOutputView(@runner)
    @runCommandView = new RunCommandView(@runner)

    @subscriptions = atom.commands.add 'atom-workspace',
      'run-command:run': => @run()
      'run-command:toggle-panel': => @togglePanel(),
      'run-command:kill-last-command': => @killLastCommand()

  deactivate: ->
    @runCommandView.destroy()
    @commandOutputView.destroy()

  dispose: ->
    @subscriptions.dispose()



  run: ->
    @runCommandView.show()

  togglePanel: ->
    if @commandOutputView.isVisible()
      @commandOutputView.hide()
    else
      @commandOutputView.show()

  killLastCommand: ->
    @runner.kill()
