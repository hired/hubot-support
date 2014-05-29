_          = require 'lodash'
$          = require 'jquery'
page       = require 'page.js/index'
Backbone   = require 'backbone'
Backbone.$ = $
ChatView   = require './chat_view.coffee'
NameView   = require './name_view.coffee'
{Message, SystemMessage, UserMessage, SupportMessage} = require './chat_models.coffee'

messages = chatView = primus = clientId = userName = null

startChatView = ->
  welcomeMessage = new SystemMessage body: 'Welcome to Hired Chat Support'
  messages       = new Backbone.Collection [
    new SystemMessage(body: 'Welcome to Hired Chat Support.'),
    new SystemMessage(body: "You are known as #{userName}.")
  ]

  chatView       = new ChatView
    el: $ '#chat'
    collection: messages
  .render()

  chatView.on 'message', (message) ->
    unless clientId
      messages.push new SystemMessage body: 'Client is not authorized'
    else
      primus.write
        clientId: clientId
        type: 'message'
        body: message

chatData = (data) ->
  console.log 'chatData', data
  if data.type == 'identify'
    window.localStorage.clientId = clientId = data.clientId
    window.localStorage.userName = userName = data.name
  else if data.type == 'message'
    if data.from == clientId
      messages.push new UserMessage body: data.body
    else if data.from == 'bot'
      messages.push new SystemMessage body: data.body
    else
      messages.push new SupportMessage from: data.from, body: data.body
  else
    console.log 'chatData', data

chatError = (err) ->
  messages.push new SystemMessage body: "Error: #{err}"

chatReconnecting = ->
  messages.push new SystemMessage body: 'Attempting to reconnect...'

chatEnd = ->
  console.log 'chatEnd'

identifyToServer = ->
  {clientId, userName} = window.localStorage
  primus.write
    clientId: clientId
    name: userName
    type: 'identify'

startChatSupport = ->
  primus = new Primus "#{window.location.protocol}//#{window.location.host}"
  primus.on 'data', chatData
  primus.on 'error', chatError
  primus.on 'reconnecting', chatReconnecting
  primus.on 'end', chatEnd
  primus.on 'open', ->
    identifyToServer()

    if chatView
      messages.push new SystemMessage body: 'Reconnected.'
    else
      startChatView()

$ ->
  redirect = (ctx, path) ->
    ctx.canonicalPath = path
    ctx.save()
    console.log 'redirect', path
    process.nextTick -> page path

  page '/chat-support.html', (ctx) ->
    redirect ctx, '/chat-support'

  page '/chat-support', (ctx) ->
    if window.localStorage.userName
      startChatSupport()
    else
      redirect ctx, '/chat-support/collect-name'

  page '/chat-support/collect-name', (ctx) ->
    nameView = (new NameView).render()
    nameView.on 'submitted', ({name}) ->
      window.localStorage.userName = userName = name
      page '/chat-support'

  page()
