do ()->
  cbs = []

  Make "Reaction", (name, cb)->
    if cb?
      (cbs[name] ?= []).push cb
    else
      throw "Null reference passed to Reaction() with name: #{name}"
  
  Make "Action", (name, args...)->
    cb args... for cb in cbs[name] if cbs[name]?
    undefined
