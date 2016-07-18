Take ["Resize", "SVG", "TopBar", "TRS", "SVGReady"], (Resize, SVG, TopBar, TRS)->
  
  g = TRS SVG.create "g", SVG.root
  SVG.create "rect", g, x: -200, y:-30, width: 400, height: 60, rx: 30, ry: 30, fill: "#222", "fill-opacity": 0.9
  SVG.create "text", g, y: 15, textContent: "Click To Focus", "font-size": 20, fill: "#FFF", "alignment-baseline": "middle", "text-anchor": "middle"
  
  show = ()-> SVG.attrs g, style: "display: block"
  hide = ()-> SVG.attrs g, style: "display: none"
  Resize ()-> TRS.abs g, x: window.innerWidth/2, y: TopBar.height
  
  window.addEventListener "focus", hide
  window.addEventListener "touchstart", hide
  window.addEventListener "blur", show
  show()
  
  window.focus() # Focus by default
