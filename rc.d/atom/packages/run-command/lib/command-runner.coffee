{BufferedProcess, Emitter, CompositeDisposable} = require 'atom'
path = require 'path'
pty = require 'pty.js'

module.exports =
class CommandRunner
  constructor: ->
    @subscriptions = new CompositeDisposable()
    @emitter = new Emitter()

  spawnProcess: (command) ->
    shell = atom.config.get('run-command.shellCommand') || '/bin/bash'
    useLogin = atom.config.get('run-command.useLoginShell')

    args = ['-c', command]
    if useLogin
      args = ['-l'].concat(args)

    console.log('args:', args)
    @term = pty.spawn shell, ['-c', command],
      name: 'xterm-color'
      cwd: @constructor.workingDirectory()
      env: process.env

    @term.on 'data', (data) =>
      @emitter.emit('data', data)
    @term.on 'exit', =>
      @emitter.emit('exit')

  @homeDirectory: ->
    process.env['HOME'] || process.env['USERPROFILE'] || '/'

  @workingDirectory: ->
    editor = atom.workspace.getActiveTextEditor()
    activePath = editor?.getPath()
    relative = atom.project.relativizePath(activePath)
    if activePath?
      relative[0] || path.dirname(activePath)
    else
      atom.project.getPaths()?[0] || @homeDirectory()

  onCommand: (handler) ->
    @emitter.on 'command', handler
  onData: (handler) ->
    @emitter.on 'data', handler
  onExit: (handler) ->
    @emitter.on 'exit', handler
  onKill: (handler) ->
    @emitter.on 'kill', handler

  run: (command) ->
    new Promise (resolve, reject) =>
      @kill()
      @emitter.emit('command', command)

      result =
        output: ''
        exited: false
        signal: null

      @spawnProcess(command)

      @subscriptions.add @onData (data) =>
        result.output += data
      @subscriptions.add @onExit =>
        result.exited = true
        resolve(result)
      @subscriptions.add @onKill (signal) =>
        result.signal = signal
        resolve(result)

  kill: (signal) ->
    signal ||= 'SIGTERM'

    if @term?
      @emitter.emit('kill', signal)
      process.kill(@term.pid, signal)
      @term.destroy()
      @term = null

      @subscriptions.dispose()
      @subscriptions.clear()
