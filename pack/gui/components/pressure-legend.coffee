Take ["GUI", "Pressure", "SVG", "Scope", "SVGReady"], (GUI, Pressure, SVG, Scope)->
  return
  
  pressures = Scope SVG.create "g", GUI.elm
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
