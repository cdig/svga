Take ["GUI", "Mode", "Resize", "SVG", "TRS", "SVGReady"], (GUI, Mode, Resize, SVG, TRS)->
  return unless Mode.nav
  
  g = TRS SVG.create "g", GUI.elm
  SVG.create "rect", g, x: -200, y:-30, width: 400, height: 60, rx: 30, fill: "#222", "fill-opacity": 0.9
  SVG.create "text", g, y: 22, textContent: "Click To Focus", "font-size": 20, fill: "#FFF", "text-anchor": "middle"
  
  show = ()-> SVG.attrs g, style: "display: block"
  hide = ()-> SVG.attrs g, style: "display: none"
  Resize ()->
    throw "HAMMERTIME"
    TRS.abs g, x: SVG.svg.offsetWidth/2
  
  window.addEventListener "focus", hide
  window.addEventListener "touchstart", hide
  window.addEventListener "blur", show
  
  # This makes IE happier
  window.addEventListener "mousedown", ()-> window.focus() if document.activeElement is SVG.svg
  
  window.focus() # Focus by default
  hide() # Fix a flicker on IE
