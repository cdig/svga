Take ["GUI","Pressure","Reaction","Resize","SVG","TRS","Tween1"],
(      GUI , Pressure , Reaction , Resize , SVG , TRS , Tween1)->
  
  u = 36
  g = TRS SVG.create "g", SVG.root
  
  pressures = TRS SVG.create "g", g
  TRS.move pressures, -84, 0
  title = SVG.create "text", pressures, x:84, y:0, "text-anchor":"middle", textContent: "What do the colors mean?", "font-size":24
  vacRect  = SVG.create "rect", pressures, x:0,  y:0*u+20,   width:u, height:u, fill: Pressure Pressure.vacuum
  atmRect  = SVG.create "rect", pressures, x:0,  y:1*u+20,   width:u, height:u, fill: Pressure Pressure.drain
  minRect  = SVG.create "rect", pressures, x:0,  y:2*u+20,   width:u, height:u, fill: Pressure Pressure.min
  medRect  = SVG.create "rect", pressures, x:0,  y:3*u+20,   width:u, height:u, fill: Pressure Pressure.med
  maxRect  = SVG.create "rect", pressures, x:0,  y:4*u+20,   width:u, height:u, fill: Pressure Pressure.max
  vacLabel = SVG.create "text", pressures, x:u+8, y:1*u+10, "text-anchor":"start", textContent: "Suction Pressure"
  atmLabel = SVG.create "text", pressures, x:u+8, y:2*u+10, "text-anchor":"start", textContent: "Drain Pressure"
  minLabel = SVG.create "text", pressures, x:u+8, y:3*u+10, "text-anchor":"start", textContent: "Low Pressure"
  medLabel = SVG.create "text", pressures, x:u+8, y:4*u+10, "text-anchor":"start", textContent: "Medium Pressure"
  maxLabel = SVG.create "text", pressures, x:u+8, y:5*u+10, "text-anchor":"start", textContent: "High Pressure"
  
  Resize ()->
    x = window.innerWidth/2
    y = GUI.TopBar.height * 2
    TRS.abs g, x: x, y: y
  
  
  alpha = 1
  do tick = (v = 0)->
    alpha = v
    SVG.styles g, opacity: alpha * 2 - 1
    TRS.scale g, alpha / 10 + .9
  Reaction "Help:Show", ()-> Tween1 alpha, 1, 1.7, tick
  Reaction "Help:Hide", ()-> Tween1 alpha, 0, 1.7, tick
