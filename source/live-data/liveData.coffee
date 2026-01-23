class LiveData
	constructor: (@ui, @webRTCTools, @debug)->
		if @debug.debugMode
			console.log "[Live Data] %cVersion 1.0.0", "color: darkgreen"

		# Link the webRTC connection state change to the GUI
		@webRTCTools.onConnectionStateChange @passStateToUI

		@webRTCTools.onConnectionUserInfoChange = (text) =>
			@ui.setConnectButtonText(text);
		
		@cachedData = new Map() # key: default channel name, value: data on that channel
		@aliasIndex = new Map()  # key: alias name, value: array of targets
		@descriptions = new Map() # key: target, value: registration description

		@ui.updateChannelName = (oldName, newName) =>
			# Find the alias that currently holds this target
			alias = @findAliasForTarget oldName

			# Remove the target from the alias
			if alias
				@removeTargetFromAlias alias, oldName

			# Find the alias that matches newName (or create it if it doesn't exist [])
			# Add oldName as a target to that newly found/created alias
			targets = @aliasIndex.get newName
			if targets?
				targets.push oldName unless oldName in targets
				@aliasIndex.set newName, targets
			else
				@aliasIndex.set newName, [oldName]

			@debug.log "linked channel", newName, "->", oldName

		@ui.attemptConnect = (sc) =>
			@webRTCTools.connect(sc)

		@ui.attemptDisconnect = () =>
			@webRTCTools.disconnect()

		@webRTCTools.onData = (data) =>
			try
				packet = JSON.parse data
				return unless Array.isArray(packet) and packet.length is 2

				for target in @aliasIndex.get(packet[0])
					@cachedData.set target, packet[1]
			catch e
				console.warn "Malformed WebRTC input data, must be of form [A,B]", e
				return

	findAliasForTarget: (target) =>
		@debug.log @aliasIndex
		for [alias, targets] from @aliasIndex
			return alias if target in targets
		null

	removeTargetFromAlias: (alias, target) =>
		targets = @aliasIndex.get alias
		return false unless Array.isArray targets

		idx = targets.indexOf target
		return false if idx is -1

		targets.splice idx, 1

		# clean up empty aliases
		@aliasIndex.delete alias if targets.length is 0

		true

			
	passStateToUI: (state) =>
		@debug.log("PASS STATE TO UI", state);
		@ui.setState(state)
		if state == "closed" or state == "disconnected" or state == "failed"
			@cachedData.clear()
	
	showConnectionTools: ->
		@ui.showConnectionTools();
		@ui.setDescriptions @descriptions, @aliasIndex

	registerChannel: (channel, description) =>

		if @descriptions.has channel
			console.warn "[Live Data] Tried to register channel #{channel} more than once. Using previous registration."
			return

		@aliasIndex.set channel, [channel]
		@descriptions.set channel, description

		if @ui.connectionToolsCreated
			@ui.setDescriptions @descriptions, @aliasIndex


	useSignalingHost: (host) ->
		@webRTCTools.useSignalingHost(host);

	getChannel: (channel, defaultValue=null) ->
		return @cachedData.get(channel.toString()) || defaultValue

	sendChannel: (channel, value) ->
		return unless typeof channel is 'number' or (typeof channel is 'string' and channel.length > 0)
		return unless typeof value is 'number' and isFinite value

		@webRTCTools.sendData JSON.stringify [channel.toString(), value]


Take ["LiveDataGUI", "WebRTCTools", "LiveDataDebug"], (liveDataGUI, webRTCTools, debug)->
	Make "LiveData", new LiveData liveDataGUI, webRTCTools, debug