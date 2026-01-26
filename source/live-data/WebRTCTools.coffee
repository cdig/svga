class WebRTCTools
  constructor: (@debug) ->
    @connectionId = 0 # Incremented on every connection

    @sc = null
    @connectionState = 'closed'
    @connectionStateChange = null # Callback function when connection state changes
    @connectionTimeoutTaredownSeconds = 5

    @pc = null
    @dataChannel = null
    @pendingRemoteCandidates = []
    @remoteIceGatheringComplete = false
    @localIceGatheringComplete = false

    @signalingHost = "https://livedata.cdig.cloud"

    if @debug.params.has('live-data-signaling-server')
      @signalingHost = @debug.params.get('live-data-signaling-server')

    @debug.log "USING SIGNALING SERVER:", @signalingHost
    @socket = null

  openForConnection: ->
    @pc is null

  useSignalingHost: (host) ->
    @signalingHost = host;

  onCommand: (command) ->
    @debug.log "got command: #{command}. Overwrite this function"

  startTaredownTimer: ->
    @cancelTaredown()
    @tareDownTimeout = setTimeout =>
      return if @pc?.iceConnectionState in ['checking', 'connected']
      @tareDownConnection()
    , @connectionTimeoutTaredownSeconds * 1000

  connect: (specialCode) ->
    return unless @openForConnection()

    @pendingRemoteCandidates = []
    @remoteIceGatheringComplete = false
    @localIceGatheringComplete = false

    @connectionId++
    cid = @connectionId

    @sc = specialCode
    @updateConnectionState "loading"
    @onConnectionUserInfoChange "Connecting..."

    @startTaredownTimer()

    @socket = io @signalingHost+"?type=WebClient"

    @socket.on "connect_error", (e) =>
      @debug.log "LBSConnectClient can't reach signaling server", e

    @socket.on 'connect', =>
      @remoteIceGatheringComplete = false
      @localIceGatheringComplete = false

      @updateConnectionState "signaling"
      @onConnectionUserInfoChange "Signaling..."
      @startTaredownTimer()

      # Create peer connection
      @pc = new RTCPeerConnection
        iceServers: [{ urls: "stun:stun.l.google.com:19302" }]

      # Data channel creation
      @dataChannel = @pc.createDataChannel "data" # UDP-like For the transfer of sensor/actuator data

      @dataChannel.onmessage = (event) =>
        @onData event.data

      # ICE connection state changes
      @pc.oniceconnectionstatechange = =>
        return unless cid is @connectionId
        @debug.log "ICE state:", @pc.iceConnectionState
        switch @pc.iceConnectionState
          when "new"
            @updateConnectionState "new"
          when "connecting"
            @updateConnectionState "connecting"
          when "connected"
            @updateConnectionState "connected"
            @cancelTaredown()
            @debug.log "P2P connection established!"
          when "checking"
            @debug.log "Checking ICE candidates"
            @startTaredownTimer()
          when "disconnected"
            @updateConnectionState "disconnected"
            @tareDownConnection()
          when "failed"
            @updateConnectionState "failed"
            @debug.log "P2P connection failed due to network issues"
            @tareDownConnection()
          when "closed"
            @updateConnectionState "closed"
            @tareDownConnection()

      # Send ICE candidates
      @pc.onicecandidate = (event) =>
        return unless cid is @connectionId
        return unless event.candidate?
        @debug.log "Got ICE candidate", event.candidate
        @socket.emit "ICEcandidate",
          candidatePackage: event.candidate
          sc: @sc

      # Receive ICE candidates
      @socket.on "ICEcandidate", ({ candidatePackage }) =>
        @debug.log "Added remote ICE candidate", candidatePackage
        if @pc.remoteDescription?
          @pc.addIceCandidate candidatePackage
        else
          @pendingRemoteCandidates.push candidatePackage

      # Local ICE gathering
      @pc.onicegatheringstatechange = =>
        return unless cid is @connectionId
        @debug.log "ICE gathering state:", @pc.iceGatheringState
        if @pc.iceGatheringState is "complete"
          @debug.log "Local ICE gathering finished"
          @localIceGatheringComplete = true
          if @remoteIceGatheringComplete
            @socket.disconnect()

      # Remote ICE gathering complete
      @socket.on "gatheringDone", =>
        @debug.log "Remote ICE gathering finished"
        @remoteIceGatheringComplete = true
        if @localIceGatheringComplete
          @socket.disconnect()

      # Create offer and send it
      @pc.createOffer
        offerToReceiveAudio: false
        offerToReceiveVideo: false
      .then (offer) =>
        return unless cid is @connectionId
        @debug.log "Created offer", offer
        @pc.setLocalDescription offer
        @socket.emit 'SDPoffer',
          offerPackage: offer
          sc: @sc

      # Listen for answer
      @socket.on "SDPanswer", ({ answerPackage }) =>
        return unless cid is @connectionId
        @debug.log "Got remote SDP answer", answerPackage
        @pc.setRemoteDescription answerPackage
        for c in @pendingRemoteCandidates
          @pc.addIceCandidate c
        @pendingRemoteCandidates = []

      @socket.on "disconnected", =>
        @debug.log "Disconnected from signaling server"

  disconnect: ->
    @tareDownConnection()

  onData: (data)->
    @debug.log("Please override WebRTCTools::onData(data)");

  onConnectionUserInfoChange: (text) ->
    @debug.log("Please override onConnectionUserInfoChange(text)")

  sendData: (data) ->
    return unless @dataChannel?
    return unless @dataChannel.readyState is 'open'

    @dataChannel.send JSON.stringify({data:data})

  sendCommand: (topic, data) ->
    return unless @dataChannel?
    return unless @dataChannel.readyState is 'open'

    @dataChannel.send JSON.stringify({command:topic, data:data})
    console.log {command:topic, data:data}

  cancelTaredown: ->
    clearTimeout @tareDownTimeout

  tareDownConnection: ->
    @cancelTaredown()
    @debug.log "P2P took too long to connect, beginning taredown"

    if @socket?
      @socket.disconnect()
    @socket = null

    if @pc?
      # Close all data channels
      for dc in @pc.dataChannels? when dc.readyState isnt "closed"
        dc.close()
      
      @pc.onicecandidate = null
      @pc.oniceconnectionstatechange = null
      @pc.onicegatheringstatechange = null

      @pc.close()
      @pc = null
      @dataChannel = null

    @remoteIceGatheringComplete = false
    @localIceGatheringComplete = false
    @pendingRemoteCandidates = []

    @updateConnectionState "closed"
    @debug.log "Done taredown. Safe to try reconnection."

  onConnectionStateChange: (fn) ->
    @connectionStateChange = fn

  updateConnectionState: (connectionState) ->
    @connectionState = connectionState
    if @connectionStateChange
      @connectionStateChange @connectionState

Take ["LiveDataDebug"], (debug) ->
  Make "WebRTCTools", new WebRTCTools debug