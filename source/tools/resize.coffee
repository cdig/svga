Take ["RAF"], (RAF)->
  Make "Resize", (cb, now = false)->
    r = ()-> RAF cb, true
    if now then cb() else r()
    window.addEventListener "resize", r
    
    # Do another bunch of resizes once everything is done loading,
    # since the page layout might shift for any number of reasons
    Take "load", ()->
      r()
      setTimeout r, 1000
      setTimeout r, 1010
      setTimeout r, 3000
      setTimeout r, 3010
      setTimeout r, 5000
      setTimeout r, 5010
      setTimeout r, 7500
      setTimeout r, 7510
      setTimeout r, 10000
      setTimeout r, 10010
      setTimeout r, 20000
      setTimeout r, 20010
      setTimeout r, 60000
      setTimeout r, 60010
