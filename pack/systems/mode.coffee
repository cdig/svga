# Config is defined in the config.coffee in every SVGA

Take ["Config", "ParentObject"], (Config, ParentObject)->
  
  fetch = (name)->
    attrName = "x-" + name
    if ParentObject.hasAttribute attrName
      JSON.parse ParentObject.getAttribute attrName
    else
      Config[name]
  
  Make "Mode", Mode =
    background: fetch "background"
    controlPanel: fetch "controlPanel"
    dev: window.top.location.port?.length >= 4
    nav: fetch "nav"
    embed: window isnt window.top
