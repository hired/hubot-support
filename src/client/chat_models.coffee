{Model} = require 'backbone'

Message = class extends Model

SystemMessage = class extends Message
  initialize: ->
    @set 'from', 'System Message'

UserMessage = class extends Message
  initialize: ->
    @set 'from', 'You'

SupportMessage = class extends Message

module.exports =
  Message: Message
  SystemMessage: SystemMessage
  UserMessage: UserMessage
  SupportMessage: SupportMessage
