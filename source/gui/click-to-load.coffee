Take ["Resize", "root", "SVG", "TRS", "SVGReady"], (Resize, root, SVG, TRS)->
  
  g = TRS SVG.create "g", SVG.root
  SVG.create "rect", g, x: -400, y:-100, width: 800, height: 200, fill: "#aaa"
  SVG.create "text", g, textContent: "Click To Load", "font-size": 100, fill: "#FFF", "alignment-baseline": "middle", "text-anchor": "middle"
  
  SVG.attrs root.mainStage.element, style: "opacity: 0.05"
  
  Resize ()->
    TRS.abs g, x: window.innerWidth/2, y: window.innerHeight/2
  
  Take "click", ()->
    SVG.attrs g, style: "display: none"
    SVG.attrs root.mainStage.element, style: "opacity: 1"
