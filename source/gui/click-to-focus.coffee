Take ["GUI", "Resize", "SVG", "TopBar", "TRS", "SVGReady"], (GUI, Resize, SVG, TopBar, TRS)->
  
  g = TRS SVG.create "g", GUI.elm
  SVG.create "rect", g, x: -200, y:-30, width: 400, height: 60, rx: 30, fill: "#222", "fill-opacity": 0.9
  SVG.create "text", g, y: 22, textContent: "Click To Focus", "font-size": 20, fill: "#FFF", "text-anchor": "middle"
  
  show = ()-> SVG.attrs g, style: "display: block"
  hide = ()-> SVG.attrs g, style: "display: none"
  Resize ()-> TRS.abs g, x: window.innerWidth/2, y: GUI.TopBar.height
  
  window.addEventListener "focus", hide
  window.addEventListener "touchstart", hide
  window.addEventListener "blur", show
  
  # This makes IE happier
  window.addEventListener "mousedown", ()-> window.focus() if document.activeElement is SVG.root
  
  window.focus() # Focus by default
  hide() # Fix a flicker on IE
