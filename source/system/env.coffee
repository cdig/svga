# Env
# Infers information about the current runtime environment.

do ()->
  
  hasPort = window.top.location.port.length > 0
  
  Make "Env", Object.freeze Env =
    dev: hasPort
