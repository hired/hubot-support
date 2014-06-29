Primus = require 'primus'
Client = require './src/server/client'
express = require 'express'
{inspect} = require 'util'
path = require 'path'
_ = require 'lodash'

if dir = process.env.HUBOT_SUPPORT_FRONTEND_DIR
  FE_DIR = path.resolve dir
else
  FE_DIR = "#{__dirname}/public"

supportIsActive = true
module.exports = (robot) ->
  console.log "Loading frontend from #{FE_DIR}"
  robot.router.use express.static FE_DIR

  _.each ['/', '/chat-support', '/chat-support/collect-name'], (route) ->
    robot.router.get route, (req, res) ->
      res.redirect '/chat-support.html'
      res.end()

  robot.respond /support ([^ ]+) (.+)/, (msg) ->
    client   = msg.match[1]
    message  = msg.match[2]

    Client.respond client,
      body: message
      from: msg.message.user.name

  robot.respond /support$/, (msg) ->
    Client.writeToChat """
      Support is #{if supportIsActive then "enabled" else "disabled"}
      Currently connected clients:
      #{(_.map Client.clients, (c) -> inspect [c.name, c.id]).join "\n"}
    """

  robot.respond /enable support/, (msg) -> supportIsActive = true
  robot.respond /disable support/, (msg) -> supportIsActive = false
  robot.respond /end support ([^ ]+)/, (msg) ->
    client = msg.match[1]
    Client.kill client

  primus = new Primus robot.server,
    transformer: 'browserchannel'

  Client.writeToChat = (message) -> robot.messageRoom '#chatSupport', message

  primus.on 'connection', (spark) ->
    client = new Client spark: spark

    notifyInactiveAndKill client unless supportIsActive

    spark.on 'end', -> client.closed()
    spark.on 'data', (message) -> Client.receive client, message
    spark.on 'error', (err) -> Client.writeToChat """
      ```
      Chat support error onoes!
      #{client.id} had an error: #{err}
      ```
    """

notifyInactiveAndKill = (client) ->
  lines = [
    "Chat support is currently closed.",
    "Please email your talent advocate or client executive."
    "I am a robot, but I still hope you have a nice day."
  ]

  _.each lines, (line) ->
    client.respond from: 'bot', body: line

  client.kill()
