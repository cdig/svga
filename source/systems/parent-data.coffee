do ()->
  
  if window is window.top
    Make "ParentData", null # Make sure you check Mode.embed before using ParentData, hey?
    return
  
  channel = new MessageChannel()
  port = channel.port1
  inbox = {}
  outbox = {}
  listeners = []
  id = window.location.pathname.replace(/^\//, "") + window.location.hash
  
  finishSetup = ()->
    finishSetup = null
    
    Make "ParentData",
      send: (k,v)->
        if outbox[k] isnt v
          outbox[k] = v
          port.postMessage "#{k}:#{v}"
      
      get: (k)->
        inbox[k]
      
      listen: (cb)->
        listeners.push cb
        cb inbox
  
  port.addEventListener "message", (e)->
    if e.data is "INIT"
      finishSetup?()
    else
      parts = e.data.split ":"
      inbox[parts[0]] = parts[1] if parts.length > 0
      cb inbox for cb in listeners
  
  window.top.postMessage "Channel:#{id}", "*", [channel.port2] # TODO: Restrict the origin
  port.postMessage "#{k}:#{v}" for k,v of outbox
  
  port.start()
