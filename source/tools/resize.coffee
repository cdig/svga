Take ["RAF"], (RAF)->
  Make "Resize", (cb, now = false)->
    r = ()-> RAF cb, true
    if now then cb() else r()
    window.addEventListener "resize", r

    # Do another couple resizes once everything is done loading,
    # since the page layout might have shifted
    Take "load", ()->
      r()
      setTimeout r, 500
