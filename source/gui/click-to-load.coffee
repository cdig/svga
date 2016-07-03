Take ["Resize", "root", "SVG", "TRS", "SVGReady"], (Resize, root, SVG, TRS)->
  
  g = TRS SVG.create "g", SVG.root
  SVG.create "rect", g, x: -420, y:-100, width: 840, height: 200, rx: 50, ry: 50, fill: "#222", "fill-opacity": 0.9
  SVG.create "text", g, textContent: "Click To Activate", "font-size": 80, y: 5, fill: "#FFF", "alignment-baseline": "middle", "text-anchor": "middle"
  
  do show = ()->
    SVG.attrs g, style: "display: block"
    SVG.attrs root.mainStage.element, style: "opacity: 0.4"
  
  Resize ()->
    TRS.abs g, x: window.innerWidth/2, y: window.innerHeight/2
  
  window.addEventListener "focus", ()->
    SVG.attrs g, style: "display: none"
    SVG.attrs root.mainStage.element, style: "opacity: 1"
  
  window.addEventListener "blur", show
    
