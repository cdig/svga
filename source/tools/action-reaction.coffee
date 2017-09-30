do ()->
  cbs = []

  Make "Reaction", (name, cb)->
    (cbs[name] ?= []).push cb
  
  Make "Action", (name, args...)->
    cb args... for cb in cbs[name] if cbs[name]?
    undefined
