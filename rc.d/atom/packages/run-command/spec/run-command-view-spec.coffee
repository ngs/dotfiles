{Editor} = require 'atom'
CommandRunner = require '../lib/command-runner'
RunCommandView = require '../lib/run-command-view'

describe "RunCommandView", ->
  beforeEach ->
    @runner = new CommandRunner()
    @view = new RunCommandView(@runner)

  it "runs a command on confirmation", ->
    spyOn(@runner, 'run')

    @view.commandEntryView.setText('echo "foo"')
    @view.confirm()

    expect(@runner.run).toHaveBeenCalledWith('echo "foo"')

  it "doesn't run empty commands", ->
    spyOn(@runner, 'run')

    @view.commandEntryView.setText('  \n  \t\r\n')
    @view.confirm()

    expect(@runner.run).not.toHaveBeenCalled()

  it "hides itself on cancellation", ->
    spyOn(@runner, 'run')
    spyOn(@view, 'hide')

    @view.commandEntryView.setText('echo "foo"')
    @view.cancel()

    expect(@view.hide).toHaveBeenCalled()
    expect(@runner.run).not.toHaveBeenCalled()

  it "cancels the view when the command entry view loses focus", ->
    spyOn(@view, 'cancel')

    @view.focus()
    @view.commandEntryView.blur()

    expect(@view.cancel).toHaveBeenCalled()
