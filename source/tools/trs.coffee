# These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
# They're not to be used by content, since they might endure breaking changes at any time.
# They may be used by Controls, since those are a more advanced feature of SVGA.

Take ["RAF", "SVG"], (RAF, SVG)->
  
  TRS = (elm, debugColor)->
    if not elm? then console.log elm; throw new Error "^ Null element passed to TRS(elm)"
    wrapper = SVG.create "g", elm.parentNode, xTrs: ""
    SVG.append wrapper, elm
    if debugColor? then SVG.create "rect", wrapper, class: "Debug", x:-2, y:-2, width:4, height:4, fill:debugColor
    elm._trs = v =
      x: 0, y: 0, r: 0, sx: 1, sy: 1, ox: 0, oy: 0,
      apply: ()->
        if "translate(#{v.x},#{v.y}) rotate(#{v.r*360}) scale(#{v.sx},#{v.sy})".indexOf("NaN") > 0 then throw "BATMAN!"
        SVG.attr wrapper, "transform", "translate(#{v.x},#{v.y}) rotate(#{v.r*360}) scale(#{v.sx},#{v.sy})"
        SVG.attr elm, "transform", "translate(#{-v.ox},#{-v.oy})"
    elm # Composable

  
  TRS.abs = (elm, attrs)->
    if not elm?._trs? then console.log elm; throw new Error "^ Non-TRS element passed to TRS.abs(elm, attrs)"
    if not attrs? then console.log elm; throw new Error "^ Null attrs passed to TRS.abs(elm, attrs)"
    # The order in which these are applied is super important.
    # If we change the order, it'll change the outcome of everything that uses this to do more than one operation per call.
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
    if attrs.now
      elm._trs.apply()
    else
      RAF elm._trs.apply, true, 1
    elm # Composable
  
  TRS.rel = (elm, attrs)->
    if not elm?._trs? then console.log elm; throw new Error "^ Non-TRS element passed to TRS.abs(elm, attrs)"
    if not attrs? then console.log elm; throw new Error "^ Null attrs passed to TRS.abs(elm, attrs)"
    # The order in which these are applied is super important.
    # If we change the order, it'll change the outcome of everything that uses this to do more than one operation per call.
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
    if attrs.now
      elm._trs.apply()
    else
      RAF elm._trs.apply, true, 1
    elm # Composable
  
  TRS.move = (elm, x = 0, y = 0)->
    if not elm._trs? then console.log elm; throw new Error "^ Non-TRS element passed to TRS.move"
    TRS.abs elm, x:x, y:y # Composable
  
  TRS.rotate = (elm, r = 0)->
    if not elm._trs? then console.log elm; throw new Error "^ Non-TRS element passed to TRS.rotate"
    TRS.abs elm, r:r # Composable
  
  TRS.scale = (elm, sx = 1, sy = sx)->
    if not elm._trs? then console.log elm; throw new Error "^ Non-TRS element passed to TRS.scale"
    TRS.abs elm, sx:sx, sy:sy # Composable
  
  TRS.origin = (elm, ox = 0, oy = 0)->
    if not elm._trs? then console.log elm; throw new Error "^ Non-TRS element passed to TRS.origin"
    TRS.abs elm, ox:ox, oy:oy # Composable
  
  
  Make "TRS", TRS
