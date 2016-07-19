Take ["Action","Control","GUI","Pressure","Reaction","Resize","SVG","TRS","Tween1","ScopeReady"],
(      Action , Control , GUI , Pressure , Reaction , Resize , SVG , TRS , Tween1)->
  
  g = TRS SVG.create "g", SVG.root
  
  sliders = TRS SVG.create "g", g, "text-anchor": "middle"
  TRS.move sliders, -128
  slider = Control
    name: "Background"
    type: "Slider"
    parent: sliders
    change: (v)->
      Action "Background:Set", v *.7 + 0.3
  
  Reaction "Background:Set", (v)->
    slider.set (v - .3) / .7
  
  Resize ()->
    x = window.innerWidth/2
    y = GUI.TopBar.height * 2
    TRS.abs g, x: x, y: y
  
  alpha = 1
  do tick = (v = 0)->
    alpha = v
    SVG.styles g, opacity: alpha * 2 - 1
  
  Reaction "Settings:Show", ()-> Tween1 alpha, 1, 1.7, tick
  Reaction "Settings:Hide", ()-> Tween1 alpha, 0, 1.7, tick
