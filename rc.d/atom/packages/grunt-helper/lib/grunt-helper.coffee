GruntHelperView = require './grunt-helper-view'

module.exports =
  gruntHelperView: null

  activate: (state) ->
    @gruntHelperView = new GruntHelperView(state.gruntHelperViewState)

  deactivate: ->
    @gruntHelperView.destroy()

  serialize: ->
    gruntHelperViewState: @gruntHelperView.serialize()
