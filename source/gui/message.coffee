Take ["DOOM", "Resize", "SVG", "Wait", "SVGReady"], (DOOM, Resize, SVG, Wait)->

  # This is added to SVG.svg, not GUI.elm, so that it floats above spotlights
  foreignObject = SVG.create "foreignObject", SVG.svg, id: "message"
  outer = DOOM.create "div", foreignObject, id: "message-outer"
  inner = DOOM.create "div", outer, id: "message-inner"

  Resize ()->
    SVG.attrs foreignObject,
      width: window.innerWidth
      height: window.innerHeight

  Message = (html, time = 2)->
    DOOM inner, innerHTML: html
    DOOM outer, opacity: 1
    Wait time, ()-> DOOM outer, opacity: 0

  # This is used so that spotlights can be prepended before it
  Message.elm = foreignObject

  Make "Message", Message
