Take "SVG", (SVG)->
  
  Make "Highlighter", Highlighter =
    setup: ()-> throw "Highligher has been removed from SVGA. Please remove the calls to Highligher.setup() from your animation."
    enable: ()-> throw "Highligher has been removed from SVGA. Please remove the calls to Highligher.enable() from your animation."
    disable: ()-> throw "Highligher has been removed from SVGA. Please remove the calls to Highligher.disable() from your animation."
  
  
  # OLD IMPLEMENTATION
  # enabled = true
  # Make "Highlighter", Highlighter =
  #   setup: (highlighted = [])->
  #
  #     mouseOver = (e)->
  #       if enabled
  #         for highlight in highlighted
  #           SVG.attr highlight, "filter", "url(#highlightMatrix)"
  #
  #     mouseLeave = (e)->
  #       for highlight in highlighted
  #         SVG.attr highlight, "filter", null
  #
  #     for highlight in highlighted
  #       highlight.addEventListener "mouseover", mouseOver
  #       highlight.addEventListener "mouseleave", mouseLeave
  #
  #   enable: ()->
  #     enabled = true
  #
  #   disable: ()->
  #     enabled = true
  #
  # SVG.createColorMatrixFilter "highlightMatrix", ".5  0   0    0   0
  #                                                 .5  1   .5   0  20
  #                                                 0   0   .5   0   0
  #                                                 0   0   0    1   0"
  #
  # NOTE: SVG.createColorMatrixFilter has been removed, but here's what it did:
  # createColorMatrixFilter: (name, values)->
  #   filter = SVG.create "filter", defs, id: name
  #   SVG.create "feColorMatrix", filter, in: "SourceGraphic", type: "matrix", values: values
  #   filter # Not Composable
