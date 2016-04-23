chrome.browserAction.onClicked.addListener ()->
    chrome.tabs.query {active: true, currentWindow: true},(tabs)->
        console.log "send request"
        chrome.tabs.sendMessage tabs[0].id,"init",(data)->
            console.log "sendShowRequestDone",data