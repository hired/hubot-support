Primus = require 'primus'
Client = require './src/client'
express = require 'express'
{inspect} = require 'util'
_ = require 'lodash'

module.exports = (robot) ->
  robot.router.use express.static "#{__dirname}/public"

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
      Currently connected clients:
      #{(_.map Client.clients, (c) -> inspect [c.name, c.id]).join "\n"}
    """

  primus = new Primus robot.server,
    transformer: 'browserchannel'

  Client.writeToChat = (message) -> robot.messageRoom '#chatSupport', message

  primus.on 'connection', (spark) ->
    client = new Client spark: spark

    spark.on 'end', -> client.closed()
    spark.on 'data', (message) -> Client.receive client, message
    spark.on 'error', (err) -> Client.writeToChat """
      ```
      Chat support error onoes!
      #{client.id} had an error: #{err}
      ```
    """

