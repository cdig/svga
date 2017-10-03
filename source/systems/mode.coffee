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
  
  Make "Mode", Mode =
    get: fetchAttribute
    background: fetchAttribute "background"
    controlPanel: fetchAttribute "controlPanel"
    dev: window.top.location.port?.length >= 4
    nav: fetchAttribute "nav"
    embed: window isnt window.top
