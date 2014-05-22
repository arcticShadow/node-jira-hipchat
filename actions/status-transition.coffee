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
module.exports = class StatusTransition 


    @_roomExists: ->
        # if project name exists in room list
        console.log @hipchat.api.listrooms
    @_notify: ->
        #send to HipChat
        
    constructor: (args) ->
        @jira = args.jira
        
        @hipchat = args.hipchat
        
        
        
        @_roomExists()
        @_notify        
