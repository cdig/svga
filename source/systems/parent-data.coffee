do ()->
  
  if window is window.top
    Make "ParentData", null # Make sure you check Mode.embed before using ParentData, hey?
    return
  
  channel = new MessageChannel()
  port = channel.port1
  open = false
  inbox = {}
  outbox = {}
  listeners = []
  
  Make "ParentData",
    send: (k,v)->
      if outbox[k] isnt v
        outbox[k] = v
        port.postMessage "#{k}:#{v}" if open
    
    get: (k)->
      inbox[k]
    
    listen: (cb)->
      listeners.push cb
      cb inbox
  
  port.addEventListener "message", (e)->
    parts = e.data.split ":"
    inbox[parts[0]] = parts[1] if parts.length > 0
    cb inbox for cb in listeners
  
  window.addEventListener "message", (e)->
    # TODO: Add origin checks
    # return unless e.origin is window.origin or e.origin.indexOf("https://cdn.lunchboxsessions.com") is 0
    
    if e.data is "RequestHandshake"
      window.top.postMessage "Handshake", "*" # TODO: Restrict the origin
    
    if e.data is "RequestChannel"
      window.top.postMessage "Channel", "*", [channel.port2] # TODO: Restrict the origin
      open = true
      port.postMessage "#{k}:#{v}" for k,v of outbox
  
  port.start()
  
  window.top.postMessage "Handshake", "*" # TODO: Restrict the origin
  
