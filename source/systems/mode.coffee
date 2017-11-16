# Config is defined in the config.coffee in every SVGA

Take ["Config", "ParentElement"], (Config, ParentElement)->
  
  fetchAttribute = (name)->
    attrName = "x-" + name
    if ParentElement.hasAttribute attrName
      # This isn't ideal, but it is good enough for now
      val = ParentElement.getAttribute attrName
      return true if val is "" or val is "true"
      return false if val is "false"
      return JSON.parse(val) if val.charAt(0) is "{"
      return val
    else
      Config[name]
  
  isDev = ()->
    loc = window.top.location
    # Allow turning off dev mode when running locally
    return false if loc.search.indexOf("dev=false") > 0
    # Allow turning on dev mode when running in prod
    return true if loc.search.indexOf("dev=true") > 0
    # By default, dev mode is active when we have a URL with a port number
    return loc.port?.length >= 4
  
  Mode =
    get: fetchAttribute
    background: fetchAttribute "background"
    controlPanel: fetchAttribute "controlPanel"
    dev: isDev()
    nav: fetchAttribute "nav"
    embed: window isnt window.top
    settings: fetchAttribute "settings"
  
  # We always disallow nav in embed mode
  Mode.nav = false if Mode.embed
  
  Make "Mode", Mode
