class LiveDataDebug
    constructor: ->
        @params = new URLSearchParams(window.location.search);
        @debugMode = @params.has("live-data-debug")
    
    log: (args...) ->
        return unless @debugMode
        console.log "[Live Data]", args...

Make "LiveDataDebug", new LiveDataDebug()
