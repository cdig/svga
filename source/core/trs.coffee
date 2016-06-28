Take ["RequestDeferredRender", "SVG"], (RequestDeferredRender, SVG)->

  err = (elm, message)->
    console.log elm
    throw "^ " + message
  
  setup = (wrapper, elm)->
    elm._trs = v =
      x: 0
      y: 0
      r: 0
      sx: 1
      sy: 1
      ox: 0
      oy: 0
      apply: ()->
        SVG.attr wrapper, "transform", "translate(#{v.x},#{v.y}) rotate(#{v.r*360}) scale(#{v.sx},#{v.sy})"
        SVG.attr elm, "transform", "translate(#{-v.ox},#{-v.oy})"
  
  
  TRS = (elm)->
    if not elm? then err elm, "Null element passed to TRS(elm)"
    if not elm.parentNode? then err elm, "Element passed to TRS(elm) must have a parentNode"
    wrapper = SVG.create "g", elm.parentNode, class: "TRS"
    # Uncomment for debug
    # SVG.create "rect", wrapper, class: "Debug", x:-4, y:-4, width:8, height:8
    setup wrapper, elm
    SVG.append wrapper, elm
    elm # Composable
  
  
  TRS.abs = (elm, attrs)->
    if not elm?._trs? then err elm, "Non-TRS element passed to TRS.abs(elm, attrs)"
    if not attrs? then err elm, "Null attrs passed to TRS.abs(elm, attrs)"
    attrs.sx = attrs.sy = attrs.scale if attrs.scale?
    elm._trs.x = attrs.x if attrs.x?
    elm._trs.y = attrs.y if attrs.y?
    elm._trs.r = attrs.r if attrs.r?
    elm._trs.sx = attrs.sx if attrs.sx?
    elm._trs.sy = attrs.sy if attrs.sy?
    if attrs.ox?
      delta = attrs.ox - elm._trs.ox
      elm._trs.ox = attrs.ox
      elm._trs.x += delta
    if attrs.oy?
      delta = attrs.oy - elm._trs.oy
      elm._trs.oy = attrs.oy
      elm._trs.y += delta
    RequestDeferredRender elm._trs.apply, true
    elm # Composable
  
  TRS.rel = (elm, attrs)->
    if not elm?._trs? then err elm, "Non-TRS element passed to TRS.abs(elm, attrs)"
    if not attrs? then err elm, "Null attrs passed to TRS.abs(elm, attrs)"
    elm._trs.x += attrs.x if attrs.x?
    elm._trs.y += attrs.y if attrs.y?
    elm._trs.r += attrs.r if attrs.r?
    elm._trs.sx += attrs.sx if attrs.sx?
    elm._trs.sy += attrs.sy if attrs.sy?
    if attrs.ox?
      elm._trs.ox += attrs.ox
      elm._trs.x += attrs.ox
    if attrs.oy?
      elm._trs.oy += attrs.oy
      elm._trs.y += attrs.oy
    RequestDeferredRender elm._trs.apply, true
    elm # Composable
  
  TRS.move = (elm, x, y)->
    if not elm._trs? then err elm, "Non-TRS element passed to TRS.move"
    TRS.abs elm, x:x, y:y # Composable
  
  TRS.rotate = (elm, r)->
    if not elm._trs? then err elm, "Non-TRS element passed to TRS.rotate"
    TRS.abs elm, r:r # Composable
  
  TRS.scale = (elm, sx, sy = x)->
    if not elm._trs? then err elm, "Non-TRS element passed to TRS.scale"
    TRS.abs elm, sx:sx, sy:sy # Composable
  
  TRS.origin = (elm, ox, oy)->
    if not elm._trs? then err elm, "Non-TRS element passed to TRS.origin"
    TRS.abs elm, ox:ox, oy:oy # Composable
  
  
  Make "TRS", TRS
