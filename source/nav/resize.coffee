do ()->
  cbs = []

  Resize = (cb)->
    cbs.push cb
  
  Resize._fire = (info)->
    for cb in cbs
      cb info
    undefined
  
  Make "Resize", Resize
  
