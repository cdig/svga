# Config is defined in the config.coffee in every SVGA

Take ["Config", "ParentObject"], (Config, ParentObject)->
  
  fetchAttribute = (name)->
    attrName = "x-" + name
    if ParentObject.hasAttribute attrName
      # This isn't ideal, but it is good enough for now
      val = ParentObject.getAttribute attrName
      switch val
        when ""
          true
        when "true"
          true
        when "false"
          false
        else
          val
    else
      Config[name]
  
  Make "Mode", Mode =
    autosize: fetchAttribute "autosize"
    background: fetchAttribute "background"
    controlPanel: fetchAttribute "controlPanel"
    dev: window.top.location.port?.length >= 4
    nav: fetchAttribute "nav"
    embed: window isnt window.top
