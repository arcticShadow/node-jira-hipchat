###
StatusTransition expects the constructor args to contain 
{
    jira: {
        issue,
        change,
        user
    },
    hipchat: {
        api: (the hipchat nodejs module)
    }
    
}
###
hipchat = require "node-hipchat"
HC = new hipchat 'f8603a027110f8c1b4249b41b0bea8'
_ = require "underscore"

class StatusTransition 
    constructor: (@args) ->
        #console.log @args
        #console.log @args.jira
        #console.log @args.jira.issue
        
        @roomname = 'Client: ' + @args.jira.issue.fields.project.name
        
    _roomExists: ->
        console.log "Checking rooms"
        
        return 1 if @roomExists
        
        HC.listRooms (data) ->
            room = _.findWhere data.rooms,
                name: @roomname
                
            if !room 
                @_createRoom() #this no longer referes to the class context. fuck
            else
                @notify
        return 0

    notify: ->
        console.log "Sending to HipChat"
        #send to HipChat
        @_sendNotify() if @_roomExists()

    _createRoom: ->
        HC.createRoom
            name: @roomname
        , @notify
        
        @roomExists true
        
exports = module.exports = StatusTransition