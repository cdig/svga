Take ["Ease", "FPS", "Gradient", "Input", "RAF", "Reaction", "SVG", "Tick", "SVGReady"], (Ease, FPS, Gradient, Input, RAF, Reaction, SVG, Tick)->

  enabled = true
  activeHighlight = null
  counter = 0
  lgradient = Gradient.linear "LightHighlightGradient", gradientUnits: "userSpaceOnUse", "#9FC", "#FF8", "#FD8"
  mgradient = Gradient.linear "MidHighlightGradient",   gradientUnits: "userSpaceOnUse", "#2F6", "#FF2", "#F72"
  dgradient = Gradient.linear "DarkHighlightGradient",  gradientUnits: "userSpaceOnUse", "#0B3", "#DD0", "#D50"
  tgradient = Gradient.linear "TextHighlightGradient",  gradientUnits: "userSpaceOnUse", "#091", "#BB0", "#B30"


  Tick (time)->
    if activeHighlight? and FPS() > 20
      if ++counter%3 is 0
        props =
          x1:Math.cos(time * Math.PI) * -60 - 50
          y1:Math.sin(time * Math.PI) * -60 - 50
          x2:Math.cos(time * Math.PI) *  60 - 50
          y2:Math.sin(time * Math.PI) *  60 - 50
        Gradient.updateProps lgradient, props
        Gradient.updateProps mgradient, props
        Gradient.updateProps dgradient, props
        Gradient.updateProps tgradient, props


  Make "Highlight", (targets...)->
    highlights = []
    active = false
    timeout = null


    setup = (elm)->
      fill = SVG.attr elm, "fill"
      stroke = SVG.attr elm, "stroke"
      width = SVG.attr elm, "stroke-width"
      doFill = fill? and fill isnt "none" and fill isnt "transparent"
      doStroke = stroke? and stroke isnt "none" and stroke isnt "transparent"
      doFunction = elm._scope?._highlight?
      if doFunction
        highlights.push e = elm: elm, function: elm._scope._highlight
        e.dontHighlightOnHover = elm._scope?._dontHighlightOnHover?
      else if doFill or doStroke
        highlights.push e = elm: elm, attrs: {}
        e.attrs.fill = fill if doFill
        e.attrs.stroke = stroke if doStroke
        e.attrs.strokeWidth = width if doStroke
        e.dontHighlightOnHover = elm._scope?._dontHighlightOnHover?
      if not doFunction
        for elm in elm.childNodes
          if elm.tagName is "g" or elm.tagName is "path" or elm.tagName is "text" or elm.tagName is "tspan" or elm.tagName is "rect" or elm.tagName is "circle"
            setup elm
      undefined


    activate = (currentTarget)-> ()->
      return if active or not enabled
      active = true
      activeHighlight?() # Deactivate any active highlight
      activeHighlight = deactivate # Set this to be the new active highlight
      timeout = setTimeout deactivate, 4000
      for h in highlights
        if h.dontHighlightOnHover and currentTarget.element is h.elm
          # skip
        else if h.function?
          h.function true
        else
          if h.attrs.stroke?
            if h.elm.tagName is "text" or h.elm.tagName is "tspan"
              SVG.attrs h.elm, stroke: "url(#TextHighlightGradient)", strokeWidth: 3
            else if h.attrs.stroke is "#FFF" or h.attrs.stroke is "white"
              SVG.attrs h.elm, stroke: "url(#LightHighlightGradient)", strokeWidth: 3
            else if h.attrs.stroke is "#000" or h.attrs.stroke is "black"
              SVG.attrs h.elm, stroke: "url(#DarkHighlightGradient)", strokeWidth: 3
            else
              SVG.attrs h.elm, stroke: "url(#MidHighlightGradient)", strokeWidth: 3
          if h.attrs.fill?
            if h.elm.tagName is "text" or h.elm.tagName is "tspan"
              SVG.attrs h.elm, fill: "url(#TextHighlightGradient)"
            else if h.attrs.fill is "#FFF" or h.attrs.fill is "white"
              SVG.attrs h.elm, fill: "url(#LightHighlightGradient)"
            else if h.attrs.fill is "#000" or h.attrs.fill is "black"
              SVG.attrs h.elm, fill: "url(#DarkHighlightGradient)"
            else
              SVG.attrs h.elm, fill: "url(#MidHighlightGradient)"
      undefined

    deactivate = ()->
      if active
        active = false
        clearTimeout timeout
        activeHighlight = null
        for h in highlights
          if h.function?
            h.function false
          else
            SVG.attrs h.elm, h.attrs
      undefined

    # Delay running the Highlight setup code by one frame so that if fills / strokes are changed
    # by the @animate() function (eg: an @linearGradient is created), we can capture those changes.
    # See: https://github.com/cdig/svga/issues/133
    RAF ()->
      for target in targets
        if not target? then console.log targets.map((e)-> e?.element); throw new Error "Highlight called with a null element ^^^"
        t = target.element or target # Support both scopes and elements

        # Since setting up Highlight has a cost to it, we do some extra bookkeeping to make sure it's not happening every frame.
        t._HighlighterSetupCount ?= 0
        if t._HighlighterSetupCount < 100 # If we see this element more than 100 times, we're probably inside a tick
          t._HighlighterSetupCount++
          setup t
        else unless t._HighlighterSetupCountWarned
          t._HighlighterSetupCountWarned = true
          console.log "Warning: it looks like you're setting up Highlighter every frame. Don't do that."

      for target in targets
        t = target.element or target # Support both scopes and elements
        unless t._Highlighter
          t._Highlighter = true

          # Handle Mouse and Touch separately, for better perf
          mouseProps =
            moveIn: activate target
            moveOut: deactivate
          touchProps =
            down: activate target
          Input t, mouseProps, true, false
          Input t, touchProps, false, true

      undefined


  Reaction "Highlights:Set", (v)->
    enabled = v
