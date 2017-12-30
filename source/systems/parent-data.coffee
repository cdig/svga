# If we're not embedded, ParentData will never be made.
# This is deliberate — please don't write code that depends on it existing.

do ()->
  channel = new MessageChannel()
  port = channel.port1
  receivedData = {}
  
  handshakeComplete = ()->
    handshakeComplete = null # Ensure that handshakeComplete only runs once
    Make "ParentData",
      get: (k)-> receivedData[k]
      send: (k,v)-> port.postMessage "#{k}:#{v}"
  
  # Listen for messages containing "k:v" data from the parent
  port.addEventListener "message", (e)->
    parts = e.data.split ":"
    receivedData[parts[0]] = parts[1]
    handshakeComplete?()
  
  # Listen for handshake requests, which might happen if we are running before the module JS runs
  window.addEventListener "message", (e)->
    # TODO: Add origin checks
    # return unless e.origin is window.origin or e.origin.indexOf("https://cdn.lunchboxsessions.com") is 0
    if e.data is "RequestHandshake"
      # TODO: Restrict the origin
      window.top.postMessage "Handshake", "*"
      
    if e.data is "RequestChannel"
      # TODO: Restrict the origin
      window.top.postMessage "Handshake", "*", [channel.port2]
  
  # Open the port
  port.start()
    
  # TODO: Handle the error case where we are embedded, but we fail to handshake
  
  # Initiate the handshake with our parent context
  sendHandshake()
