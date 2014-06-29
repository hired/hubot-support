crypto = require 'crypto'
_      = require 'lodash'

class Client
  @clients: []
  @add: (client) -> @clients.push client
  @drop: (client) -> @clients = _.without @clients, client
  @findByName: (name) -> _.find @clients, (c) -> c.name == name
  @findById: (id) -> _.find @clients, (c) -> c.id == id
  @findByNameOrId: (nameOrId) -> @findByName(nameOrId) || @findById(nameOrId)
  @uniqueId: ->
    buf = crypto.randomBytes 5
    id = buf.toString 'base64'
    if @findById id then @uniqueId() else id

  @uniqueName: (name) ->
    name = name.toLowerCase().replace /\s+/g, '-'
    if @findByName name
      @uniqueName "_#{name}"
    else
      name

  @receive: (client, message) ->
    if message.type == 'identify'
      name = clientId = returning = null

      if clientId = message.clientId
        # Returning user, see if we can re-use
        # their old name
        oldClient = Client.findById(clientId)
        if oldClient?.name == message.name
          name = message.name
          returning = true
          oldClient.end "Session resumed in another browser window/tab."
        else
          name = Client.uniqueName message.name
      else
        name     = Client.uniqueName message.name
        clientId = Client.uniqueId()

      client.identify
        name: name
        id: clientId
        returning: returning
    else
      client.receive message

  @respond: (nameOrId, message) -> @findByNameOrId(nameOrId).respond message
  @kill: (nameOrId) -> @findByNameOrId(nameOrId).kill()

  id: 'not set'
  constructor: ({@spark}) -> Client.add @
  toString: -> "#<Client id:#{@id} name:#{@name}>"
  respond: (message) -> @spark.write _.extend message, type: 'message'
  receive: (message) ->
    if @id != message.clientId
      @end("Message must contain a valid client id")

    if message.type == 'message'
      Client.writeToChat "#{@name}: #{message.body}"
      @spark.write
        type: 'message'
        body: message.body
        from: @name

  identify: (opts) ->
    _.extend @, _.pick(opts, 'id', 'name', 'spark', 'returning')

    verb = if @returning then "returned to" else "joined"
    Client.writeToChat "@channel: #{@} has #{verb} chat support."
    @spark.write
      type: 'identify'
      name: @name
      clientId: @id

  kill: -> @spark.write type: 'kill'

  end: (message) ->
    @closed()
    @respond
      body: "Ended session: #{message}"
      from: 'bot'

  closed: ->
    Client.clients = _.without Client.clients, @
    Client.writeToChat "#{@} has left chat."


module.exports = Client
