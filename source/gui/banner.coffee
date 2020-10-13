Take ["DOOM", "GUI", "Resize", "SVG", "Wait", "SVGReady"], (DOOM, GUI, Resize, SVG, Wait)->

  foreignObject = SVG.create "foreignObject", GUI.elm, id: "svga-banner"
  outer = DOOM.create "div", foreignObject, id: "svga-banner-outer"
  inner = DOOM.create "div", outer, id: "svga-banner-inner"

  Resize ()->
    SVG.attrs foreignObject,
      width: window.innerWidth
      height: window.innerHeight

  Banner = (html, time)->
    DOOM inner, innerHTML: html
    DOOM outer, opacity: 1
    Wait time, Banner.hide if time?

  Banner.hide = ()->
    DOOM outer, opacity: 0

  Make "Banner", Banner
