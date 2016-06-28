Take ["RequestDeferredRender", "SVG"], (RequestDeferredRender, SVG)->
  
  makeProps = (p, c, props)->
    c._trs = trs =
      x: 0
      y: 0
      r: 0
      sx: 1
      sy: 1
      ox: 0
      oy: 0
      go: ()->
        SVG.attr p, "transform", "translate(#{trs.ox},#{trs.oy}) rotate(#{trs.r})"
        SVG.attr c, "transform", "translate(#{trs.ox-trs.x},#{trs.oy-trs.y}) scale(#{trs.sx},#{trs.sy})"
        
  
  Make "TRS", TRS =
    create: (parent)->
      p = SVG.create "g", parent, class: "TRS P"
      c = SVG.create "g", p, class: "TRS C"
      makeProps p, c
      c # Composable
    
    move: (elm, x, y = 0)->
      elm._trs.x = x
      elm._trs.y = y
      RequestDeferredRender elm._trs.go, true
      elm # Composable
    
    rotate: (elm, r)->
      elm._trs.r = r * 360
      RequestDeferredRender elm._trs.go, true
      elm # Composable
    
    origin: (elm, ox, oy)->
      elm._trs.ox = ox if ox?
      elm._trs.oy = oy if oy?
      RequestDeferredRender elm._trs.go, true
      elm # Composable
    
    scale: (elm, x, y = x)->
      elm._trs.sx = x
      elm._trs.sy = y
      RequestDeferredRender elm._trs.go, true
      elm # Composable
