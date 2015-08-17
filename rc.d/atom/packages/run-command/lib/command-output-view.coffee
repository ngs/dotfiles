{CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'
{CommandRunner} = require './command-runner'
Utils = require './utils'

module.exports =
class CommandOutputView extends View
  @content: ->
    @div class: 'command-runner', =>
      @header class: 'panel-heading', =>
        @span 'Command: '
        @span class: 'command-name', outlet: 'header'
      @div class: 'panel-body', outlet: 'outputContainer', =>
        @pre class: 'command-output', outlet: 'output'

  attrs: null

  initialize: (runner) ->
    @panel = atom.workspace.addBottomPanel
      item: @,
      visible: false

    @subscriptions = new CompositeDisposable()
    @subscriptions.add = runner.onCommand (command) =>
      @setCommand(command)
    @subscriptions.add = runner.onData (data) =>
      @addOutput(data)
    @subscriptions.add = runner.onExit =>
      @setExited()
    @subscriptions.add = runner.onKill (signal) =>
      @setKillSignal(signal)

  destroy: ->
    @subscriptions.destroy()

  show: ->
    @panel.show()
    @scrollToBottomOfOutput()

  hide: ->
    @panel.hide()

  isVisible: ->
    @panel.isVisible()



  atBottomOfOutput: ->
    @output[0].scrollHeight <= @output.scrollTop() + @output.outerHeight()

  scrollToBottomOfOutput: ->
    @output.scrollToBottom()



  setCommand: (command) ->
    @clearOutput()
    @header.text(command)
    @show()

  clearOutput: ->
    @output.empty()



  classesForAnsiCodes: (codes) ->
    codes?.map (code) ->
      switch code
        when 39 then  'ansi-default-fg'
        when 30 then  'ansi-black-fg'
        when 31 then  'ansi-red-fg'
        when 32 then  'ansi-green-fg'
        when 33 then  'ansi-yellow-fg'
        when 34 then  'ansi-blue-fg'
        when 35 then  'ansi-magenta-fg'
        when 36 then  'ansi-cyan-fg'
        when 37 then  'ansi-light-gray-fg'
        when 90 then  'ansi-dark-gray-fg'
        when 91 then  'ansi-light-red-fg'
        when 92 then  'ansi-light-green-fg'
        when 93 then  'ansi-light-yellow-fg'
        when 94 then  'ansi-light-blue-fg'
        when 95 then  'ansi-light-magenta-fg'
        when 96 then  'ansi-light-cyan-fg'
        when 97 then  'ansi-white-fg'

        when 49 then  'ansi-default-bg'
        when 40 then  'ansi-black-bg'
        when 41 then  'ansi-red-bg'
        when 42 then  'ansi-green-bg'
        when 43 then  'ansi-yellow-bg'
        when 44 then  'ansi-blue-bg'
        when 45 then  'ansi-magenta-bg'
        when 46 then  'ansi-cyan-bg'
        when 47 then  'ansi-light-gray-bg'
        when 100 then 'ansi-dark-gray-bg'
        when 101 then 'ansi-light-red-bg'
        when 102 then 'ansi-light-green-bg'
        when 103 then 'ansi-light-yellow-bg'
        when 104 then 'ansi-light-blue-bg'
        when 105 then 'ansi-light-magenta-bg'
        when 106 then 'ansi-light-cyan-bg'
        when 107 then 'ansi-white-bg'
    .filter((x) -> x?)

  attrsForCodes: (codes) ->
    attrs = {}
    for code in codes
      switch code
        when 0
          attrs.fg = 'default'
          attrs.bg = 'default'

        when 39 then attrs.fg = 'default'
        when 30 then attrs.fg = 'black'
        when 31 then attrs.fg = 'red'
        when 32 then attrs.fg = 'green'
        when 33 then attrs.fg = 'yellow'
        when 34 then attrs.fg = 'blue'
        when 35 then attrs.fg = 'magenta'
        when 36 then attrs.fg = 'cyan'
        when 37 then attrs.fg = 'light-gray'
        when 90 then attrs.fg = 'dark-gray'
        when 91 then attrs.fg = 'light-red'
        when 92 then attrs.fg = 'light-green'
        when 93 then attrs.fg = 'light-yellow'
        when 94 then attrs.fg = 'light-blue'
        when 95 then attrs.fg = 'light-magenta'
        when 96 then attrs.fg = 'light-cyan'
        when 97 then attrs.fg = 'white'

        when 49 then attrs.bg = 'default'
        when 40 then attrs.bg = 'black'
        when 41 then attrs.bg = 'red'
        when 42 then attrs.bg = 'green'
        when 43 then attrs.bg = 'yellow'
        when 44 then attrs.bg = 'blue'
        when 45 then attrs.bg = 'magenta'
        when 46 then attrs.bg = 'cyan'
        when 47 then attrs.bg = 'light-gray'
        when 100 then attrs.bg = 'dark-gray'
        when 101 then attrs.bg = 'light-red'
        when 102 then attrs.bg = 'light-green'
        when 103 then attrs.bg = 'light-yellow'
        when 104 then attrs.bg = 'light-blue'
        when 105 then attrs.bg = 'light-magenta'
        when 106 then attrs.bg = 'light-cyan'
        when 107 then attrs.bg = 'white'
    attrs

  applyCodesToAttrs: (codes, attrs) ->
    next = @attrsForCodes(codes)
    $.extend({}, attrs || {}, next)

  classesForAttrs: (attrs) ->
    ["ansi-fg-#{attrs?.fg || 'default'}", "ansi-bg-#{attrs?.bg || 'default'}"]

  createOutputNode: (text) ->
    node = $('<span />').text(text)
    parent = $('<span />').append(node)

    colorCodeRegex = /\x1B\[([0-9;]*)m/g
    colorizedHtml = parent.html().replace colorCodeRegex, (_, matches) =>
      codes = matches?.split(';')
                .map((x) -> parseInt(x, 10))
                .filter((x) -> !isNaN(x))

      if codes.length == 0
        codes = [0]

      @attrs = @applyCodesToAttrs(codes, @attrs)
      classes = @classesForAttrs(@attrs)

      "</span><span class='#{classes.join(' ')}'>"

    parent.html(colorizedHtml)



  addOutput: (data, classes) ->
    atBottom = @atBottomOfOutput()

    node = @createOutputNode(data)

    if classes?
      node.addClass(classes.join(' '))

    @output.append(node)

    if atBottom
      @scrollToBottomOfOutput()

  setExited: ->
    message = 'Command exited\n'
    @addOutput(message, ['exit', 'exited'])

  setKillSignal: (signal) ->
    message = 'Command killed with signal ' + signal + '\n'
    @addOutput(message, ['exit', 'kill-signal'])
