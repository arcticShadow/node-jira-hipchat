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
        @roomExists = false
        @userid = 836115
        @HipChatStatus =
            wip: 
                color: "yellow"
            fail: 
                color: "red"
            done: 
                color: "green"
            internalTesting: 
                color: "blue"
            externalTesting: 
                color: "purple"
            default: 
                color: "gray"

        
        fromStatesThatIndicateFail = [
            "External Testing"
            "Internal Testing"
            "Code Review"
        ]
        @roomname = 'Project: ' + @args.jira.issue.fields.project.name
        @issue = @args.jira.issue
        @issueChange = @args.jira.change
        console.log @issueChange.toString
        switch @issueChange.toString
            when "Backlog" or "Ready" 
		if @issueChange.fromString in fromStatesThatIndicateFail
                    @issueStatus = @HipChatStatus.fail
            when "Work In Progress"
                @issueStatus = @HipChatStatus.wip
            when "Done"
                @issueStatus = @HipChatStatus.done
            when "Internal Testing"
                @issueStatus = @HipChatStatus.internalTesting
            when "External Testing"
                @issueStatus = @HipChatStatus.externalTesting
            else
                @issueStatus = @HipChatStatus.default
            
        
    _roomExists: ->
        console.log "Checking rooms"
        
        return @roomExists if @roomExists
        
        HC.listRooms (a,b,c) =>
            
            room = _.findWhere a.rooms,
                name: @roomname
            
            
            if !room 
                @_createRoom() #this now referes to the class context. The magical fat arrow
            else
                @roomid = room.room_id
                @roomExists = true
                @notify()
        return false

    notify: ->
        console.log "Sending to HipChat"
        #send to HipChat
        @_sendNotify() if @_roomExists()

    _createRoom: ->
        console.log "Creating Room"
        #@_getUser()
        HC.createRoom
            name: @roomname
            owner_user_id: @userid
        , (a,b,c) =>
            console.log a, b, c
            
            hc_response_error = JSON.parse b
            hc_response = JSON.parse a
            
            if not hc_response?.error?
                @roomid = hc_response.room.room_id
            else
                @notify()
                @roomExists = true
                
            @roomExists
    
    _sendNotify: ->
        console.log "Posting Message in color #{@issueStatus.color}"
        issuekey = @args.jira.issue.key
        issuename = @args.jira.issue.fields.summary
        issueOldStatus = @args.jira.change.fromString
        issueNewStatus = @args.jira.change.toString
        HC.postMessage 
            room_id: @roomid
            from:    @args.jira.user.displayName
            message: "<b>(#{issuekey}) #{issuename}</b><br><br><b>Status Changed</b><br> #{issueOldStatus} -> #{issueNewStatus}"
            notify:   0
            color:   @issueStatus.color
            message_format:  'html'
        , (a,b,c) ->
            console.log a,b,c
            
exports = module.exports = StatusTransition
