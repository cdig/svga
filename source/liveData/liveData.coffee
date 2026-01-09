class LiveData
    constructor: (@ui, @webRTCTools)->

        # Link the webRTC connection state change to the GUI
        @webRTCTools.onConnectionStateChange @passStateToUI
        
        @cachedData = new Map()

        @ui.attemptConnect = (sc) =>
            @webRTCTools.connect(sc)

        @ui.attemptDisconnect = () =>
            @webRTCTools.disconnect()

        @webRTCTools.onData = (data) =>
            try
                packet = JSON.parse data
                return unless Array.isArray(packet) and packet.length is 2
                @cachedData.set packet[0], packet[1]
            catch e
                console.warn "Malformed WebRTC input data, must be of form [A,B]", e
                return
    
    passStateToUI: (state) =>
        console.log("PASS STATE TO UI", state);
        @ui.setState(state)
        if state == "closed" or state == "disconnected" or state == "failed"
            @cachedData.clear()
    
    showConnectionTools: ->
        @ui.showConnectionTools();
    
    useSignalingHost: (host) ->
        @webRTCTools.useSignalingHost(host);

    getChannel: (channel, defaultValue=null) ->
        return @cachedData.get(channel.toString()) || defaultValue

    sendChannel: (channel, value) ->
        return unless typeof channel is 'number' or (typeof channel is 'string' and channel.length > 0)
        return unless typeof value is 'number' and isFinite value

        @webRTCTools.sendData JSON.stringify [channel.toString(), value]


Take ["LiveDataGUI", "WebRTCTools"], (liveDataGUI, webRTCTools)->
    Make "LiveData", new LiveData liveDataGUI, webRTCTools