Take ["RAF"], (RAF)->
  Make "Resize", (cb)->
    do r = ()-> RAF cb, true
    window.addEventListener "resize", r
