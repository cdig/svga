Take ["RAF"], (RAF)->
  Make "Resize", (cb, now = false)->
    r = ()-> RAF cb, true
    if now then cb() else r()
    window.addEventListener "resize", r
