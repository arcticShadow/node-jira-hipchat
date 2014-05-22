

// Include: Express Framework the clean way.
var express = require('express'),
    http = require('http'),
    app = express(),
    hipchat = require('node-hipchat');    
require('coffee-script/register');

var nconf = require('nconf');

// First consider commandline arguments and environment variables, respectively.
nconf.argv().env();

// Then load configuration from a designated file.
nconf.file({ file: 'config.json' });

// Provide default values for settings not provided above.
nconf.defaults({
    'http': {
        'port': process.env.PORT||3000
    },
    'hipchat': new hipchat('f8603a027110f8c1b4249b41b0bea8')
});


app.use(express.bodyParser());

// Default GET.
app.get('/', function (req, res)
{
    res.send('Node.js is running.');
});

// POST.
app.post('/jira', function (req, res)
{
    var jiraEvent = req.body;
    if(jiraEvent.webhookEvent == "jira:issue_updated")
    {
        var user = jiraEvent.user,
            issue = jiraEvent.issue,
            changelog = jiraEvent.changelog.items;
        console.log(changelog);
        for (var changeIndex = 0; changeIndex < changelog.length; changeIndex++)
        {
            var change = changelog[changeIndex];
            console.log(change);
            if(change.field == "status")
            {
                var transition = require("./actions/status-transition.coffee")({
                    jira: {
                        user: user,
                        change: change,
                        issue: issue
                    },
                    hipchat:{
                        api: nconf.get('hipchat')
                    }
                });
                
                break;
            }
        }
            
        
        //console.log("User: " + post_body.user.displayName);
        //console.log("Issue: " + post_body.issue.key);
        
        
    }
    res.send('Something Happened in Jira');
});

// Default.
app.all('*', debugRequest);


// Include: Socket.IO
http.createServer(app).listen(nconf.get('http:port'), function(){
  console.log('Express server listening on port ' + nconf.get('http:port'));
});

// Debugger.
function debugRequest(req, res, c) {

    console.log(req);

    // Out.
    res.send('.');
}
