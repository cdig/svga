# Clean, single-instance CoffeeScript rewrite using embedded HTML + CSS
# External API preserved:
#  - showConnectionTools()
#  - hideConnectionTools()
#  - setState(state)
#  - @ui.setDescriptions(descriptionMap, channelTable); # descriptionMap: a key (original channel name) and value (description string). channelTable is a map with key(new channel name) and value (old channel name)
#  - override: attemptConnect = (sc) =>, attemptDisconnect = () =>
#  - overide: updateChannelName = (oldName, newName) =>

class LiveDataGUI

	constructor: ->
		@connectionToolsCreated = false
		@_bindGlobalHide()

	# =======================
	# Public API
	# =======================

	showConnectionTools: ->
		return if @connectionToolsCreated
		@_injectUI()
		@connectionToolsCreated = true

	hideConnectionTools: ->
		return unless @connectionToolsCreated
		@_removeUI()
		@connectionToolsCreated = false

	_translateChannelNameInverse: (channelTable, originalName) =>
		for [newName, oldName] from channelTable
			return newName if oldName is originalName
		originalName

	setDescriptions: (descriptionMap, channelTable) ->
		# Delete all old channels
		@otpBody.innerHTML = "";
		# descriptionMap: key = originalChannelName, value = description
		for [name, description] from descriptionMap
			newName = @_translateChannelNameInverse channelTable, name
			@_insertChannel name, description, newName

		# Ensure event listners
		inputs = document.querySelectorAll '.otp-channel-input'
		for input in inputs
			input.addEventListener 'change', (e) =>
				el = e.target
				og = el.dataset.ogChannel
				value = el.value
				@updateChannelName og, value # oldName, newName

		

	setState: (status) ->
		switch status
			when 'connecting', 'loading', 'signaling', 'gathering'
				@_stateConnecting()
			when 'connected'
				@_hideOTP()
				@_stateDisconnectReady()
				@_setPlugConnected true
				@_showPlug()
			when 'disconnected'
				@_stateReset()
				@_setPlugConnected false
				@_showPlug()
			when 'closed'
				@_stateReset()
				@_hideOTP()
				@_setPlugConnected false
				@_showPlug()
			when 'failed'
				@_stateReset()
				@_setPlugConnected false
				@_showPlug()
			else
				console.log 'Unknown status:', status

	# To be overridden
	attemptConnect: (sc) ->
		console.log 'Please override attemptConnect(sc) in your implementation', sc

	attemptDisconnect: ->
		console.log 'Please override attemptDisconnect() in your implementation'

	updateChannelName: (oldName, newName) ->
		console.log 'Please override updateChannelName(oldName, newName)'

	# =======================
	# UI creation / teardown
	# =======================

	_injectUI: ->
		return if document.getElementById 'live-data-root'

		style = document.createElement 'style'
		style.id = 'live-data-style'
		style.textContent = """
		                      /* ===============================
		                       OTP Connection Panel
		                       =============================== */
		                    
		                    .otp-container {
		                      position: absolute;
		                      top: 10px;
		                      right: 10px;
		                    
		                      width: 320px;
		                      max-height: 300px;
		                    
		                      display: none;
		                      flex-direction: column;
		                      gap: 10px;
		                    
		                      background: #580061;
		                      padding: 10px 14px;
		                      border-radius: 10px;
		                      text-align: center;
		                    
		                      font-family: Lato, sans-serif;
		                    }
		                    
		                    /* ===============================
		                       Header (OTP + Buttons)
		                       =============================== */
		                    
		                    .otp-header {
		                      display: flex;
		                      align-items: center;
		                      justify-content: space-between;
		                      gap: 10px;
		                    }
		                    
		                    .otp-inputs {
		                      display: flex;
		                      gap: 5px;
		                    }
		                    
		                    .otp-inputs input {
		                      width: 30px;
		                      height: 36px;
		                      font-size: 22px;
		                      text-align: center;
		                    
		                      border-radius: 8px;
		                      border: none;
		                      outline: none;
		                    
		                      background: #760084;
		                      color: white;
		                    }
		                    
		                    .otp-inputs input:focus {
		                      border-color: #760084;
		                      box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.3);
		                    }
		                    
		                    .otp-actions {
		                      display: flex;
		                      gap: 6px;
		                    }
		                    
		                    /* ===============================
		                       Buttons
		                       =============================== */
		                    
		                    #otp-conn-button,
		                    #otp-disconn-button {
		                      border: none;
		                      border-radius: 8px;
		                      font-size: 20px;
		                      cursor: pointer;
		                      height: 36px;
		                      padding: 0 10px;
		                      color: white;
		                      background: #367f30;
		                    
		                      transition: transform 0.15s ease, filter 0.15s ease;
		                    }
		                    
		                    #otp-conn-button:hover,
		                    #otp-disconn-button:hover {
		                      transform: scale(1.02);
		                    }
		                    
		                    #otp-disconn-button {
		                      display: none;
		                    }
		                    
		                    /* ===============================
		                       Scrollable Channel List
		                       =============================== */
		                    
		                    .otp-body {
		                      flex: 1;
		                      overflow-y: auto;
		                    
		                      display: flex;
		                      flex-direction: column;
		                      gap: 6px;
		                    
		                      padding-right: 4px;
		                    }
		                    
		                    /* Individual rows */
		                    
		                    .otp-row {
		                      display: flex;
		                      align-items: normal;
		                      gap: 8px;
		                    }
		                    
		                    .otp-row input {
		                        width: 120px;
		                        height: 28px;
		                        padding: 0 6px;
		                        border-radius: 6px;
		                        border: none;
		                        outline: none;
		                        background: #760084;
		                        color: white;
		                    }
		                    
		                    .otp-row p {
		                      margin: 0;
		                      flex: 1;
		                    
		                      font-size: 14px;
		                      color: white;
		                      text-align: left;
		                    }
		                    
		                    /* ===============================
		                       Plug Button
		                       =============================== */
		                    
		                    #otp-show-button {
		                      position: absolute;
		                      top: 10px;
		                      right: 10px;
		                    
		                      height: 36px;
		                      padding: 0 10px;
		                    
		                      border: none;
		                      border-radius: 8px;
		                    
		                      font-size: 25px;
		                      cursor: pointer;
		                    
		                      background: #ff000a75;
		                    }
		                    
		                    		                    """

		root = document.createElement 'div'
		root.id = 'live-data-root'
		root.innerHTML = """
		                 <button id="otp-show-button" title="Connection">🔌</button>
		                 <div class="otp-container">
		                 
		                   <!-- Top row -->
		                   <div class="otp-header">
		                     <div class="otp-inputs">
		                       <input maxlength="1" />
		                       <input maxlength="1" />
		                       <input maxlength="1" />
		                       <input maxlength="1" />
		                     </div>
		                 
		                     <div class="otp-actions">
		                       <button id="otp-conn-button">Connect</button>
		                       <button id="otp-disconn-button">Disconnect</button>
		                     </div>
		                   </div>
		                 
		                   <!-- Scrollable body -->
		                   <div class="otp-body">
		                     <!-- more rows... -->
		                   </div>
		                 
		                 </div>
		                 		                 """

		document.head.appendChild style
		document.body.appendChild root

		@_cacheElements()
		@_wireEvents()

	_removeUI: ->
		document.getElementById('live-data-root')?.remove()
		document.getElementById('live-data-style')?.remove()

	_insertChannel: (originalName, description, newName) ->
		channel = """
			<div class="otp-row">
				<input class="otp-channel-input" value=#{newName} data-og-channel=#{originalName}></input>
				<p>#{description}</p>
			</div>
		"""
		@otpBody.innerHTML += channel

	_cacheElements: ->
		@root = document.getElementById 'live-data-root'
		@container = @root.querySelector '.otp-container'
		@inputs = Array.from @root.querySelectorAll '.otp-inputs input'
		@btnConnect = @root.querySelector '#otp-conn-button'
		@btnDisconnect = @root.querySelector '#otp-disconn-button'
		@btnPlug = @root.querySelector '#otp-show-button'
		@otpBody = @root.querySelector '.otp-body'

	_wireEvents: ->
		# OTP input behavior
		@inputs.forEach (input, i) =>
			input.addEventListener 'input', =>
				input.value = input.value.toUpperCase()
				if input.value and i < @inputs.length - 1
					@inputs[i + 1].focus()

			input.addEventListener 'keydown', (e) =>
				if e.key is 'Backspace' and not input.value and i > 0
					@inputs[i - 1].focus()

		# Buttons
		@btnConnect.addEventListener 'click', =>
			otp = @_getOTP()
			if otp.length is 4 then @attemptConnect otp
			else
				@_showPlug()
				@_hideOTP()

		@btnDisconnect.addEventListener 'click', =>
			@attemptDisconnect()

		@btnPlug.addEventListener 'click', =>
			@_showOTP()

	_bindGlobalHide: ->
		window.addEventListener 'click', (e) =>
			return unless @connectionToolsCreated
			return unless @root?

			if not @root.contains e.target
				@_hideOTP()

	# =======================
	# UI helpers
	# =======================

	_getOTP: ->
		@inputs.map((i) -> i.value).join ''

	_setInputsDisabled: (state) ->
		@inputs.forEach (i) -> i.disabled = state

	_showOTP: ->
		@container.style.display = 'flex' if @container

	_hideOTP: ->
		@container.style.display = 'none' if @container

	_showPlug: ->
		@btnPlug.style.display = 'unset' if @btnPlug

	_setPlugConnected: (connected) ->
		return unless @btnPlug
		@btnPlug.style.background = if connected then '#00ff0a75' else '#ff000a75'

	# =======================
	# State transitions
	# =======================

	_stateConnecting: ->
		@_setInputsDisabled true
		@btnConnect.style.display = 'unset'
		@btnConnect.textContent = 'Connecting ...'
		@btnConnect.disabled = true
		@btnDisconnect.style.display = 'none'

	_stateDisconnectReady: ->
		@_setInputsDisabled true
		@btnDisconnect.style.display = 'unset'
		@btnDisconnect.disabled = false
		@btnConnect.style.display = 'none'

	_stateReset: ->
		@inputs.forEach (i) -> i.value = ''
		@_setInputsDisabled false
		@btnConnect.style.display = 'unset'
		@btnConnect.textContent = 'Connect'
		@btnConnect.disabled = false
		@btnDisconnect.style.display = 'none'

Make "LiveDataGUI", new LiveDataGUI()
