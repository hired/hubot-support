{View} = require 'backbone'
_ = require 'lodash'
$ = require 'jquery'

ChatView = class extends View
  messageTemplate: _.template """
    <div class="message xs-pbh0">
      <p class="p--lead">
        <span class="message__from"><strong><%= from %></strong></span>
        <span class="message__body"><%= body %></span>
      </p>
    </div>
  """

  render: ->
    _.tap @, =>
      @$el.removeClass 'hide'
      @collection.each (message) =>
        @renderMessage message

  renderMessage: (message) ->
    @$messages.append @messageTemplate message.attributes
    @$messages.scrollTop @$messages[0].scrollHeight

  initialize: ->
    @$messages = @$ '.messages'
    @$form     = @$ 'form'
    @$input    = @$form.find 'input'
    @$button   = @$form.find 'button'
    @collection.on 'add', (message) =>
      @renderMessage message

  events:
    'submit form': (event) ->
      event.preventDefault()
      message = @$input.val()
      @$input.val ''
      @trigger 'message', message

module.exports = ChatView
