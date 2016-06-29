Take ["RequestUniqueAnimation"], (RequestUniqueAnimation)->
  Make "Resize", (cb)->
    do r = ()-> RequestUniqueAnimation cb, true
    window.addEventListener "resize", r
