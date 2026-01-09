class WebRTCTools
  constructor: ->
    @sc = null
    @connectionState = 'closed'
    @connectionStateChange = null # Callback function when connection state changes
    @connectionTimeoutTaredownSeconds = 5

    @pc = null
    @dataChannel = null
    @remoteIceGatheringComplete = false
    @localIceGatheringComplete = false

    @signalingHost = "https://lunchboxsessions.com"
    @socket = null

  openForConnection: ->
    @connectionState == 'closed' or @connectionState == 'disconnected'

  useSignalingHost: (host) ->
    @signalingHost = host;

  connect: (specialCode) ->
    return unless @openForConnection()

    @sc = specialCode
    @updateConnectionState "loading"

          # Tare down timeout
    @tareDownTimeout = setTimeout =>
      @tareDownConnection()
    , @connectionTimeoutTaredownSeconds * 1000

    @socket = io @signalingHost+"?type=WebClient"

    @socket.on "connect_error", (e) =>
      console.log "LBSConnectClient can't reach signaling server", e

    @socket.on 'connect', =>
      @remoteIceGatheringComplete = false
      @localIceGatheringComplete = false

      @updateConnectionState "signaling"

      # Create peer connection
      @pc = new RTCPeerConnection
        iceServers: [{ urls: "stun:stun.l.google.com:19302" }]

      # Data channel creation
      @dataChannel = @pc.createDataChannel "data"

      @dataChannel.onmessage = (event) =>
        @onData event.data

      # ICE connection state changes
      @pc.oniceconnectionstatechange = =>
        console.log "ICE state:", @pc.iceConnectionState
        switch @pc.iceConnectionState
          when "new"
            @updateConnectionState "new"
          when "connecting"
            @updateConnectionState "connecting"
          when "connected"
            @updateConnectionState "connected"
            @cancelTaredown()
            console.log "P2P connection established!"
          when "disconnected"
            @updateConnectionState "disconnected"
            @tareDownConnection()
          when "failed"
            @updateConnectionState "failed"
            console.log "P2P connection failed due to network issues"
            @tareDownConnection()
          when "closed"
            @updateConnectionState "closed"
            @tareDownConnection()

      # Send ICE candidates
      @pc.onicecandidate = (event) =>
        return unless event.candidate?
        console.log "Got ICE candidate", event.candidate
        @socket.emit "ICEcandidate",
          candidatePackage: event.candidate
          sc: @sc

      # Receive ICE candidates
      @socket.on "ICEcandidate", ({ candidatePackage }) =>
        console.log "Added remote ICE candidate", candidatePackage
        @pc.addIceCandidate candidatePackage

      # Local ICE gathering
      @pc.onicegatheringstatechange = =>
        console.log "ICE gathering state:", @pc.iceGatheringState
        if @pc.iceGatheringState is "complete"
          console.log "Local ICE gathering finished"
          @localIceGatheringComplete = false
          if @remoteIceGatheringComplete
            @socket.disconnect()

      # Remote ICE gathering complete
      @socket.on "gatheringDone", =>
        console.log "Remote ICE gathering finished"
        @remoteIceGatheringComplete = true
        if @localIceGatheringComplete
          @socket.disconnect()

      # Create offer and send it
      @pc.createOffer
        offerToReceiveAudio: false
        offerToReceiveVideo: false
      .then (offer) =>
        console.log "Created offer", offer
        @pc.setLocalDescription offer
        @socket.emit 'SDPoffer',
          offerPackage: offer
          sc: @sc

      # Listen for answer
      @socket.on "SDPanswer", ({ answerPackage }) =>
        console.log "Got remote SDP answer", answerPackage
        @pc.setRemoteDescription answerPackage

      @socket.on "disconnected", =>
        console.log "Disconnected from signaling server"

  disconnect: ->
    @tareDownConnection()

  onData: (data)->
    console.log("Please override WebRTCTools::onData(data)");

  sendData: (data) ->
    return unless @dataChannel?
    return unless @dataChannel.readyState is 'open'

    @dataChannel.send data

  cancelTaredown: ->
    clearTimeout @tareDownTimeout

  tareDownConnection: ->
    @cancelTaredown()
    console.log "P2P took too long to connect, beginning taredown"

    if @socket?
      @socket.disconnect()
    @socket = null

    if @pc?
      # Close all data channels
      for dc in @pc.dataChannels? when dc.readyState isnt "closed"
        dc.close()

      @pc.close()
      @pc = null
      @dataChannel = null

    @remoteIceGatheringComplete = false
    @localIceGatheringComplete = false

    @updateConnectionState "closed"
    console.log "Done taredown. Safe to try reconnection."

  onConnectionStateChange: (fn) ->
    @connectionStateChange = fn

  updateConnectionState: (connectionState) ->
    @connectionState = connectionState
    if @connectionStateChange
      @connectionStateChange @connectionState

Take ["socket.io"], ()->
  Make "WebRTCTools", new WebRTCTools()