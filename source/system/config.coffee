do ()->
  Config = (c)->
    Config[k] = v for k,v of c
  
  Config.nav = false
  Config.topBar = false
  Config.background = false
  
  Make "Config", Config
