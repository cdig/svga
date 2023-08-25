# Config is defined in the config.coffee in every SVGA

Take ["Config", "ParentData"], (Config, ParentData)->

  embedded = window isnt window.top # This logic needs to mirror the logic in ParentData

  fetchAttribute = (name)->
    if embedded and val = ParentData.get name
      # This isn't ideal, but it is good enough for now
      return true if val is "" or val is "true"
      return false if val is "false"
      return JSON.parse(val) if val.charAt(0) is "{"
      return val
    else
      Config[name]

  isDev = ()->
    
    loc = window.location
    # Allow turning off dev mode when running locally
    return false if loc.search.indexOf("dev=false") > 0
    # Allow turning on dev mode when running in prod
    return true if loc.search.indexOf("dev=true") > 0
    # By default, dev mode is active when we have a URL with a port number
    return loc.port?.length >= 3

  Mode =
    get: fetchAttribute
    background: fetchAttribute "background"
    dev: isDev()
    noNavDbl: fetchAttribute "noNavDbl"
    nav: fetchAttribute "nav"
    embed: embedded
    settings: fetchAttribute "settings"

  # We always disallow nav in embed mode
  Mode.nav = false if Mode.embed

  Make "Mode", Mode
