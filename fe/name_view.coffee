{View} = require 'backbone'
$      = require 'jquery'
_      = require 'lodash'

module.exports = class extends View
  el: -> $ '#name'
  render: ->
    _.tap @, =>
      @$el.removeClass 'hide'

  initialize: ->
    @$form   = @$ 'form'
    @$input  = @$form.find 'input'
    @$button = @$form.find 'button'

  events:
    'submit form': (event) ->
      event.preventDefault()
      @trigger 'submitted', name: @$input.val()
      @$el.addClass 'hide'
      @remove()
