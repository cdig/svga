Take "SVG", (SVG)->
  enabled = true
  
  Make "Highlighter", Highlighter =
    setup: (highlighted = [])->
      
      mouseOver = (e)->
        if enabled
          for highlight in highlighted
            SVG.attr highlight, "filter", "url(#highlightMatrix)"
      
      mouseLeave = (e)->
        for highlight in highlighted
          SVG.attr highlight, "filter", null
      
      for highlight in highlighted
        highlight.addEventListener "mouseover", mouseOver
        highlight.addEventListener "mouseleave", mouseLeave
    
    enable: ()->
      enabled = true
    
    disable: ()->
      enabled = true
  
  SVG.createColorMatrixFilter "highlightMatrix", ".5  0   0    0   0
                                                  .5  1   .5   0  20
                                                  0   0   .5   0   0
                                                  0   0   0    1   0"
