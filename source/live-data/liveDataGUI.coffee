# Clean, single-instance CoffeeScript rewrite using embedded HTML + CSS
# External API preserved:
#  - showConnectionTools()
#  - hideConnectionTools()
#  - showRequestHardwareControlBtn()
#  - hideRequestHardwareControlBtn()
#  - setState(state)
#  - @ui.setDescriptions(descriptionMap, aliasIndex); # parameters are defined in liveData.coffee
#  - override: attemptConnect = (sc) =>, attemptDisconnect = () =>
#  - overide: updateChannelName = (oldName, newName) =>
#  - overide: requestHardwareControl = () =>

class LiveDataGUI

	constructor: (@debug) ->
		@connectionToolsCreated = false
		@_pointerDownInside = false
		@_bindGlobalHide()

		# In localhost development, body is used to house the svga. In production environments, "page" is used
		@page = document.getElementById("page") ? document.body

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

	showRequestHardwareControlBtn: ->
		@requestHardwareControlDiv.style.display = 'unset'

	hideRequestHardwareControlBtn: ->
		@requestHardwareControlDiv.style.display = 'none'

	grantHardwareControl: ->
		@btnRequestHardwareControl.innerText = "Release Hardware Control"
		@btnRequestHardwareControl.style.background = "#cf8c0c";
		@btnPlug.style.background = '#00eeffe8'; # Blue for connected and controling hardware
	
	revolkHardwareControl: ->
		@btnRequestHardwareControl.innerText = "Request Hardware Control"
		@btnRequestHardwareControl.style.background = "";
		@btnPlug.style.background = '#00ff0a75'; # Green for connected

	setConnectButtonText: (text) ->
		@btnConnect.textContent = text;

	setDescriptions: (descriptionMap, aliasIndex) ->
		# Delete all old channels
		@subContainer.innerHTML = "";
		
		for [alias, targets] from aliasIndex
			for target in targets
				@_insertChannel target, descriptionMap.get(target), alias

		# Ensure event listners
		inputs = document.querySelectorAll '.otp-channel-input'
		for input in inputs
			input.addEventListener 'change', (e) =>
				el = e.target
				og = el.dataset.ogChannel
				value = el.value
				@updateChannelName og, value # oldName, newName
	
	setPublisherDescriptions: (publisherDescriptionMap) ->
		# Delete all old channels
		@pubContainer.innerHTML = "";
		for [channel, description] from publisherDescriptionMap
			@_insertPubChannel channel, description

	setState: (status) ->
		switch status
			when 'connecting', 'loading', 'signaling', 'gathering'
				@_stateConnecting()
			when 'connected'
				@_hideOTP()
				@_stateDisconnectReady()
				@_setPlugConnected true
				@showRequestHardwareControlBtn()
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
				@debug.log 'Unknown status:', status

	# To be overridden
	attemptConnect: (sc) ->
		@debug.log 'Please override attemptConnect(sc) in your implementation', sc

	attemptDisconnect: ->
		@debug.log 'Please override attemptDisconnect() in your implementation'

	updateChannelName: (oldName, newName) ->
		@debug.log 'Please override updateChannelName(oldName, newName)'

	requestHardwareControl: () ->
		@debug.log 'Please override requestHardwareControl()'

	clickConnect: ->
		otp = @_getOTP()
		if otp.length is 4 then @attemptConnect otp
		else
			@_showPlug()
			@_hideOTP()

	clickPlug: ->
		@_showOTP()

	# =======================
	# UI creation / teardown
	# =======================

	_injectUI: ->
		return if document.getElementById 'live-data-root'

		@disconnectedSVG = 
		"""
		<svg
		width="24"
		height="24"
		viewBox="0 0 24 24"
		fill="none"
		stroke="currentColor"
		stroke-width="2"
		stroke-linecap="round"
		stroke-linejoin="round"
		version="1.1"
		id="svg2"
		xmlns="http://www.w3.org/2000/svg"
		xmlns:svg="http://www.w3.org/2000/svg">
		<defs
			id="defs2" />
		<path
			style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:1.461;stroke-linecap:round;stroke-dasharray:none"
			id="path4-0"
			d="m 9.3765059,17.811095 a 5.8269229,5.8269229 0 0 1 -5.0462633,-2.913462 5.8269229,5.8269229 0 0 1 0,-5.8269226 5.8269229,5.8269229 0 0 1 5.0462633,-2.9134614 v 5.826923 z" />
		<path
			style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:1.461;stroke-linecap:round;stroke-dasharray:none"
			id="path4-0-3"
			d="m -14.600672,17.851888 a 5.8269229,5.8269229 0 0 1 -5.046263,-2.913461 5.8269229,5.8269229 0 0 1 0,-5.8269232 5.8269229,5.8269229 0 0 1 5.046263,-2.9134614 v 5.8269226 z"
			transform="scale(-1,1)" />
		<path
			style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:2;stroke-linecap:round;stroke-dasharray:none"
			d="M -0.08158924,11.993619 H 5.824059"
			id="path5" />
		<path
			style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:2;stroke-linecap:round;stroke-dasharray:none"
			d="m 17.918,11.994 h 5.905648"
			id="path5-8" />
		</svg>
		"""

		@connectedSVG = 
		"""
		<svg
		width="24"
		height="24"
		viewBox="0 0 24 24"
		fill="none"
		stroke="currentColor"
		stroke-width="2"
		stroke-linecap="round"
		stroke-linejoin="round"
		version="1.1"
		id="svg2"
		xmlns="http://www.w3.org/2000/svg"
		xmlns:svg="http://www.w3.org/2000/svg">
		<defs
			id="defs2" />
		<line
			x1="0"
			y1="12"
			x2="24"
			y2="12"
			id="line1" />
		<circle
			style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:1.461;stroke-linecap:round;stroke-dasharray:none"
			id="path4"
			cx="11.913462"
			cy="11.942308"
			r="5.8269229" />
		</svg>
		"""

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
							  box-shadow: 0px 2px 6px 0px #00000063;
		                    
		                      width: 320px;
		                      max-height: 300px;
		                    
		                      display: none;
		                      flex-direction: column;
		                      gap: 10px;
		                    
		                      background: #406abf;
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
		                    
		                      background: #212d59;
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
		                      cursor: pointer;
							  height:35px;
		                      padding: 0 10px;
		                      color: white;
		                    
		                      transition: transform 0.15s ease, filter 0.15s ease;
		                    }
		                    
		                    #otp-conn-button:hover,
		                    #otp-disconn-button:hover,
							.rhc-button:hover {
		                      transform: scale(1.02);
		                    }
		                    
		                    #otp-disconn-button {
		                      display: none;
		                    }

							.rhc-button {
								width: 100%;
								height: 30px;
								padding: 0px;
								color: white;
							}

							#rhc-div {
								display: none;
							}
		                    
		                    /* ===============================
		                       Scrollable Channel List
		                       =============================== */
		                    
		                    .ld-container {
		                      flex: 1;
		                      overflow-y: auto;
		                    
		                      display: flex;
		                      flex-direction: column;
		                      gap: 6px;
		                    
		                      padding-right: 4px;
		                    }

							.ld-sub-container, .ld-pub-container {
								display: flex;
								gap: 2px;
								flex-direction: column;
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
		                        color: white;
								background: #212d59;
		                    }
		                    
		                    .otp-row p {
		                      margin: 0;
		                      flex: 1;
		                    
		                      font-size: 14px;
		                      color: white;
		                      text-align: left;
		                    }

							.ld-title {
								color: white;
								background: #0000003b;
								border-radius: 5px;
								padding: 5px;
							}
		                    
		                    /* ===============================
		                       Plug Button
		                       =============================== */
		                    
		                    #otp-show-button {
		                      	position: absolute;
								top: 10px;
								right: 10px;
								height: 35px;
								/* padding: 0 10px; */
								padding: 5px;
								border: none;
								border-radius: 10px;
								cursor: pointer;
								background: #ff000a75;
		                    }
		                    
		                    		                    """

		root = document.createElement 'div'
		root.id = 'live-data-root'
		root.innerHTML = """
		                 <button id="otp-show-button" title="Connection">#{@disconnectedSVG}</button>
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

						   <div id="rhc-div">
						   		<button class='rhc-button'>Request Hardware Control</button>
						   </div>
		                 
		                   <!-- Scrollable body -->
						   <div class='ld-container'>
								<p class='ld-title'>Subscribers</p>
								<div class="ld-sub-container">
									<!-- more rows... -->
								</div>
								<p class='ld-title'>Publishers</p>
								<div class="ld-pub-container">
									<!-- more rows... -->
								</div>
						   </div>
		                 
		                 </div>
		                 		                 """

		document.head.appendChild style
		@page.appendChild root

		@_cacheElements()
		@_wireEvents()

	_removeUI: ->
		document.getElementById('live-data-root')?.remove()
		document.getElementById('live-data-style')?.remove()

	_insertChannel: (originalName, description, newName) ->
		channel = """
			<div class="otp-row">
				<input data-1p-ignore class="otp-channel-input" value=#{newName} data-og-channel=#{originalName}></input>
				<p>#{description}</p>
			</div>
		"""
		@subContainer.innerHTML += channel
	
	_insertPubChannel: (originalName, description) ->
		channel = """
			<div class="otp-row">
				<input disabled data-1p-ignore class="otp-channel-output" value=#{originalName}></input>
				<p>#{description}</p>
			</div>
		"""
		@pubContainer.innerHTML += channel

	_cacheElements: ->
		@root = document.getElementById 'live-data-root'
		@container = @root.querySelector '.otp-container'
		@inputs = Array.from @root.querySelectorAll '.otp-inputs input'
		@btnConnect = @root.querySelector '#otp-conn-button'
		@btnDisconnect = @root.querySelector '#otp-disconn-button'
		@btnRequestHardwareControl = @root.querySelector '.rhc-button'
		@requestHardwareControlDiv = @root.querySelector '#rhc-div'
		@btnPlug = @root.querySelector '#otp-show-button'
		@subContainer = @root.querySelector '.ld-sub-container'
		@pubContainer = @root.querySelector '.ld-pub-container'

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
			@clickConnect()

		@btnDisconnect.addEventListener 'click', =>
			@attemptDisconnect()

		@btnRequestHardwareControl.addEventListener 'click', =>
			@requestHardwareControl()

		@btnPlug.addEventListener 'click', =>
			@clickPlug()

	_bindGlobalHide: ->
		window.addEventListener 'pointerdown', (e) =>
			return unless @root?
			@_pointerDownInside = @root.contains e.target

		window.addEventListener 'pointerup', (e) =>
			return unless @root?

			return if @_pointerDownInside
			@_hideOTP()

	# =======================
	# UI helpers
	# =======================

	_getOTP: ->
		@inputs.map((i) -> i.value).join ''

	setOTP: (otp) ->
		@inputs.forEach (input, index) ->
			input.value = otp[index] or ''

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
		@btnPlug.style.background = if connected then '#00ff0a75' else '#ff000a75';
		@btnPlug.innerHTML = if connected then @connectedSVG else @disconnectedSVG;

	# =======================
	# State transitions
	# =======================

	_stateConnecting: ->
		@_setInputsDisabled true
		@btnConnect.style.display = 'unset'
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
		@hideRequestHardwareControlBtn()

Take ["LiveDataDebug"], (debug) ->
	Make "LiveDataGUI", new LiveDataGUI debug
