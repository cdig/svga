Take ["DOOM", "GUI", "Resize", "SVG", "Wait", "SVGReady"], (DOOM, GUI, Resize, SVG, Wait)->

  foreignObject = SVG.create "foreignObject", GUI.elm, id: "message"
  outer = DOOM.create "div", foreignObject, id: "message-outer"
  inner = DOOM.create "div", outer, id: "message-inner"

  Resize ()->
    SVG.attrs foreignObject,
      width: window.innerWidth
      height: window.innerHeight

  Make "Message", (html, time = 2)->
    DOOM inner, innerHTML: html
    DOOM outer, opacity: 1

    # Wait time, ()-> DOOM outer, opacity: 0
