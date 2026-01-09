# USAGE
# Only use the following functions:

        # @ui.showConnectionTools();
        # @ui.hideConnectionTools();
        # @ui.setState(state) # state can be: connecting connected disconnected closed failed

        # OVERWRITE THESE IN YOUR IMPLEMENTATION
        # @ui.attemptConnect = (sc) =>
        # @attemptDisconnect = () =>

# Only one instance should ever be made, and it is made with Take at the bottom of this file
class LiveDataGUI

    # constructor
    constructor: ->
        @connectionToolsCreated = false
        @_add_hide_event_listner()

    _add_hide_event_listner: ->
        window.addEventListener "click", (e) =>
            if !e.target?.class?.toString().includes 'otp'
                if @connectionToolsCreated
                    @_hide_otp();

    showConnectionTools: ->
        if !@connectionToolsCreated
            @_create_open_otp_btn()
            @_create_otp()
            @connectionToolsCreated = true

    hideConnectionTools: ->
        if @connectionToolsCreated
            @_open_otp_btn_remove()
            @_otp_remove()
            @_remove_css_tags_in_head()
            @connectionToolsCreated = false

    _create_otp: () ->

        # TODO ensure create can't run if it's already made

        # --- Create CSS ---
        css = """
        .otp-container {
            position: absolute;
            top:10px;
            right:10px;
            display:none;
            gap:10px;
            background: hsl(220, 50%, 50%);
            padding: 10px 14px;
            border-radius: 10px;
            text-align: center;
            height: 56px;
        }

        .otp-inputs {
            display: flex;
            gap: 5px;
            margin-bottom: 16px;
        }

        .otp-inputs input {
            width: 30px;
            height: 36px;
            font-size: 22px;
            text-align: center;
            border-radius: 8px;
            border: none;
            background: #3a4a92;
            color: white;
            outline: none;
        }

        .otp-inputs input:focus {
            border-color: #38bdf8;
            box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.3);
        }

        #otp-conn-button, #otp-disconn-button {
            border: none;
            border-radius: 8px;
            font-size: 20px;
            cursor: pointer;
            height:36px;
            padding:0px 10px;
        }

        #otp-disconn-button {
            display:none;
        }
        """

        styleTag = document.createElement 'style'
        styleTag.textContent = css
        styleTag.className = 'live-data-style'
        document.head.appendChild styleTag

        # --- Create OTP container ---
        otpContainer = document.createElement 'div'
        otpContainer.className = 'otp-container' # Used for the css
        otpContainer.class = 'otp-container' # Used for the mousedown logic

        # --- Create input wrapper ---
        otpInputs = document.createElement 'div'
        otpInputs.className = 'otp-inputs'

        # --- Create 4 inputs ---
        for i in [1..4]
            input = document.createElement 'input'
            input.maxLength = 1
            input.inputMode = 'numeric'
            input.class='otp-input'
            otpInputs.appendChild input

        # --- Append inputs to container ---
        otpContainer.appendChild otpInputs

        # --- Create the buttons ---
        conButton = document.createElement 'button'
        conButton.id = 'otp-conn-button'
        conButton.class = 'otp-conn-button'
        conButton.textContent = 'Connect'

        disconButton = document.createElement 'button'
        disconButton.id = 'otp-disconn-button'
        disconButton.class = 'otp-conn-button'
        disconButton.textContent = 'Disconnect'

        # --- Append buttons to container ---
        otpContainer.appendChild conButton
        otpContainer.appendChild disconButton

        # --- Add container to the body ---
        document.body.appendChild otpContainer

        # --- Implement functionality ---
        inputs = document.querySelectorAll ".otp-inputs input"

        # Auto-focus next input & backspace behavior
        inputs.forEach (input, i) ->
            input.addEventListener "input", ->
                input.value = input.value.toUpperCase();
                if input.value and i < inputs.length - 1
                    inputs[i + 1].focus()

            input.addEventListener "keydown", (e) ->
                if e.key is "Backspace" and not input.value and i > 0
                    inputs[i - 1].focus()

        # Connect button click
        document.getElementById("otp-conn-button").addEventListener "click", =>
            otp = Array.from(inputs).map((i) -> i.value).join ""
            @conButtonClick otp

        # Connect button click
        document.getElementById("otp-disconn-button").addEventListener "click", =>
            otp = Array.from(inputs).map((i) -> i.value).join ""
            @attemptDisconnect()
    
    _otp_set_input_disable_state: (state) ->
        inputs = document.querySelectorAll ".otp-inputs input"
        inputs.forEach (input, i) ->
            input.disabled = state

    _hide_otp: () ->
        ele = document.querySelector ".otp-container"
        if ele
            ele.style.display = "none"

    _show_otp: () ->
        ele = document.querySelector ".otp-container"
        if ele
            ele.style.display = "flex"

    _otp_connecting: () ->
        @_otp_set_input_disable_state true
        btn = document.getElementById("otp-conn-button")
        btn.style.display = "unset"
        btn.textContent = "Connecting ..."
        btn.disabled = true;
        document.getElementById("otp-disconn-button").style.display = "none";

    _otp_disconnect: () ->
        @_otp_set_input_disable_state true
        btn = document.getElementById("otp-disconn-button")
        btn.style.display = "unset"
        btn.textContent = "Disconnect"
        btn.disabled = false;
        document.getElementById("otp-conn-button").style.display = "none";

    _otp_reset: () ->
        inputs = document.querySelectorAll ".otp-inputs input"
        inputs.forEach (input, i) ->
            input.value = ''
        @_otp_set_input_disable_state false
        btn = document.getElementById("otp-conn-button")
        btn.style.display = "unset"
        btn.textContent = "Connect"
        btn.disabled = false;
        document.getElementById("otp-disconn-button").style.display = "none";
    
    _otp_remove: () ->
        container = document.querySelector('.otp-container')
        if container
            container.remove()

    _create_open_otp_btn: () ->

        # TODO ensure create can't run if it's already made

        # --- Create CSS ---
        css = """
        #otp-show-button {
            border: none;
            border-radius: 8px;
            font-size: 25px;
            cursor: pointer;
            height:36px;
            padding:0px 10px;
            position: absolute;
            background: #ff000a75; 
            top: 10px;
            right: 10px;
        }
        """

        styleTag = document.createElement 'style'
        styleTag.textContent = css
        styleTag.className = 'live-data-style'
        document.head.appendChild styleTag

        # --- Create OTP container ---
        button = document.createElement 'button'
        button.id = 'otp-show-button'
        button.class = 'otp-show-button'
        button.textContent = '🔌'
        button.onclick = @openOtpButtonClick.bind @


        document.body.appendChild button

    _hide_open_otp_btn: () ->
        ele = document.querySelector "#otp-show-button"
        if ele
            ele.style.display = "none"

    _show_open_otp_btn: () ->
        ele = document.querySelector "#otp-show-button"
        if ele
            ele.style.display = "unset"

    _open_otp_btn_connected: () ->
        ele = document.querySelector "#otp-show-button"
        if ele
            ele.style.background = "#00ff0a75" # GREEN

    _open_otp_btn_disconnected: () ->
        ele = document.querySelector "#otp-show-button"
        if ele
            ele.style.background = "#ff000a75" # RED

    _open_otp_btn_remove: () ->
        button = document.querySelector '#otp-show-button'
        if button
            button.remove()

    _remove_css_tags_in_head: () -> 
        styles = document.querySelectorAll ".live-data-style"
        for style in styles
            style.remove()

    # Buttons

    conButtonClick: (otp) -> 
        sc = otp;
        if sc.length == 4
            @attemptConnect sc
        else
            @_show_open_otp_btn()
            @_hide_otp()

    openOtpButtonClick: () ->
        @_show_otp()


    # Methods for interacting with otp =============
    attemptConnect: (sc) ->
        console.log("Please override attemptDisconnect(sc) in your implementation")

    attemptDisconnect: () ->
        console.log("Please override attemptDisconnect in your implementation")

    setState: (status) ->
        switch status
            when 'connecting', 'loading', 'signaling', 'gathering'
                @_otp_connecting();
            when 'connected'
                @_hide_otp();
                @_otp_disconnect();
                @_open_otp_btn_connected();
                @_show_open_otp_btn();
            when 'disconnected'
                @_otp_reset();
                @_open_otp_btn_disconnected();
                @_show_open_otp_btn();
            when 'closed'
                @_otp_reset();
                @_hide_otp();
                @_open_otp_btn_disconnected();
                @_show_open_otp_btn();
            when 'failed'
                @_otp_reset();
                @_open_otp_btn_disconnected();
                @_show_open_otp_btn();
            else
                console.log "Unknown status:", status


    # get or create a channel
    getChannel: (channel, defaultValue = null) ->
        
Make "LiveDataGUI", new LiveDataGUI()