{Editor} = require 'atom'
{$} = require 'atom-space-pen-views'
CommandRunner = require '../lib/command-runner'
CommandOutputView = require '../lib/command-output-view'

describe "CommandOutputView", ->
  beforeEach ->
    @runner = new CommandRunner()

  describe "running a command", ->
    it "shows itself", ->
      commandHandler = null
      spyOn(@runner, 'onCommand').andCallFake (handler) ->
        commandHandler = handler

      view = new CommandOutputView(@runner)
      spyOn(view, 'show')

      commandHandler('echo "foo"')

      expect(view.show).toHaveBeenCalled()

    it "displays the command", ->
      commandHandler = null
      spyOn(@runner, 'onCommand').andCallFake (handler) ->
        commandHandler = handler

      view = new CommandOutputView(@runner)
      commandHandler('echo "foo"')

      expect(view.header.text()).toEqual('echo "foo"')

    it "displays the command's output", ->
      dataHandler = null

      spyOn(@runner, 'onData').andCallFake (handler) ->
        dataHandler = handler

      view = new CommandOutputView(@runner)

      dataHandler('foo\n')
      dataHandler('bar\n')

      expect(view.output.text()).toEqual('foo\nbar\n')

    it "displays the last command's exit code", ->
      exitHandler = null

      spyOn(@runner, 'onExit').andCallFake (handler) ->
        exitHandler = handler

      view = new CommandOutputView(@runner)

      exitHandler()

      expect(view.output.text()).toMatch(/^\s*Command exited\s*$/)

    it "displays the last command's kill signal", ->
      killHandler = null

      spyOn(@runner, 'onKill').andCallFake (handler) ->
        killHandler = handler

      view = new CommandOutputView(@runner)

      killHandler('SIGKILL')

      expect(view.output.text()).toMatch(/SIGKILL/)

    it "clears the last command's output", ->
      [commandHandler, dataHandler] = [null, null]

      spyOn(@runner, 'onCommand').andCallFake (handler) ->
        commandHandler = handler
      spyOn(@runner, 'onData').andCallFake (handler) ->
        dataHandler = handler

      view = new CommandOutputView(@runner)

      commandHandler('echo "foo"; echo "bar"')
      dataHandler('foo\nbar\n')
      expect(view.output.text()).toEqual('foo\nbar\n')

      commandHandler('echo "baz"')
      dataHandler('baz\n')
      expect(view.output.text()).toEqual('baz\n')

  describe "displaying a command's output", ->
    it "stays locked to the bottom of the output area", ->
      view = new CommandOutputView(@runner)

      spyOn(view, 'atBottomOfOutput').andReturn(true)
      spyOn(view, 'scrollToBottomOfOutput')

      view.addOutput('foo')
      expect(view.scrollToBottomOfOutput).toHaveBeenCalled()

    it "unlocks from the bottom of the output area when scrolling up", ->
      view = new CommandOutputView(@runner)

      spyOn(view, 'atBottomOfOutput').andReturn(false)
      spyOn(view, 'scrollToBottomOfOutput')

      view.addOutput('foo')
      expect(view.scrollToBottomOfOutput).not.toHaveBeenCalled()

    it "colorizes the command's output", ->
      dataHandler = null

      spyOn(@runner, 'onData').andCallFake (handler) ->
        dataHandler = handler

      view = new CommandOutputView(@runner)

      dataHandler('\x1B[31mHello, \x1B[40mwro\x1B[;;;ml\x1B[md\x1B[0m!\n')

      expect(view.output.text()).toEqual('Hello, wrold!\n')
      expect($('.ansi-fg-red', view.output).text()).toEqual('Hello, wro')
      expect($('.ansi-bg-black', view.output).text()).toEqual('wro')
      expect($('.ansi-fg-default.ansi-bg-default', view.output).text())
        .toEqual('ld!\n')
