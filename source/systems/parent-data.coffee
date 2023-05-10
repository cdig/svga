Take [], ()->
  if window is window.top # This logic needs to mirror the logic for Mode.embed
    Make "ParentData", null # Make sure you check Mode.embed before using ParentData, hey?
    return

  channel = new MessageChannel()
  port = channel.port1
  port.start()
  inbox = {}
  outbox = {}
  listeners = []
  id = window.location.pathname.replace(/^\//, "") + window.location.hash


  # API ###########################################################################################

  finishSetup = ()->
    finishSetup = null

    Make "ParentData",
      send: (k,v)->
        if outbox[k] isnt v
          outbox[k] = v
          port.postMessage "#{k}:#{v}"

      get: (k)->
        inbox[k]

      # Currently only used by Nav so that we can run a resize whenever the outer context changes
      listen: (cb)->
        listeners.push cb
        cb inbox


  # RECEIVING #####################################################################################

  port.addEventListener "message", (e)->
    if e.data is "INIT"
      finishSetup?()
    else
      [k, v] = e.data.split ":"
      if k? and v?
        inbox[k] = v
        cb inbox for cb in listeners
      else
        console.log "ParentData received an unprocessable message:", e.data


  # HANDSHAKE #####################################################################################

  timeoutID = null

  window.addEventListener "message", (e)->
    if e.data is "Handshake Received"
      clearTimeout timeoutID
      window.top.postMessage "Channel:#{id}", "*", [channel.port2]

  offerHandshake = ()->
    window.top.postMessage "Handshake", "*"
    # Offer handshakes again every 100ms until the parent accepts
    timeoutID = setTimeout offerHandshake, 100

  offerHandshake()
