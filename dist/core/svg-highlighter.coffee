do ->
  enabled = true
  Make "Highlighter", Highlighter = 
    setup: (highlighted=[])->
      mouseOver = (e)->
        if enabled
          for highlight in highlighted
            highlight.setAttribute("filter", "url(#highlightMatrix)")  
      mouseLeave = (e)->
        for highlight in highlighted
          highlight.removeAttribute("filter")
      for highlight in highlighted
        highlight.addEventListener "mouseover", mouseOver
        highlight.addEventListener "mouseleave", mouseLeave

    enable: ()->
      enabled = true
    
    disable: ()->
      enabled = true


