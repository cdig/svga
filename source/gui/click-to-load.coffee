Take ["Resize", "root", "SVG", "TopBar", "TRS", "SVGReady"], (Resize, root, SVG, TopBar, TRS)->
  
  g = TRS SVG.create "g", SVG.root
  SVG.create "rect", g, x: -200, y:-30, width: 400, height: 60, rx: 30, ry: 30, fill: "#222", "fill-opacity": 0.9
  SVG.create "text", g, y: 15, textContent: "Click To Focus", "font-size": 20, fill: "#FFF", "alignment-baseline": "middle", "text-anchor": "middle"
  
  do show = ()->
    SVG.attrs g, style: "display: block"
    # SVG.attrs root.mainStage.element, style: "opacity: 0.3"
  
  Resize ()->
    TRS.abs g, x: window.innerWidth/2, y: TopBar.height
  
  window.addEventListener "focus", ()->
    SVG.attrs g, style: "display: none"
    # SVG.attrs root.mainStage.element, style: "opacity: 1"
  
  window.addEventListener "blur", show
    
