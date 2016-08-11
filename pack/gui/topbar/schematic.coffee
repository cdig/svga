Take ["Action", "Reaction", "SVG", "TopBar", "TRS", "Tween"], (Action, Reaction, SVG, TopBar, TRS, Tween)->
  icon = null
  patha = null
  pathb = null
  r = 0
  b = 0
  
  tickBG = (v)-> SVG.styles api.bg, "fill-opacity":b=v
  tickRotation = (v)-> TRS.abs icon, r:r=v
  tickDash = (v)->
    SVG.attrs patha, "stroke-dashoffset": Math.abs v * 41
    SVG.attrs pathb, "stroke-dashoffset": Math.abs v * 35
  
  TopBar "Schematic", api =
    setup: ()->
      icon = TRS api.icon
      SVG.styles api.bg, fill: "hsl(220, 50%, 60%)"
      patha = api.icon.querySelector "path.a"
      pathb = api.icon.querySelector "path.b"
      TRS.abs icon, ox: 16, oy: 24
      
      Reaction "Schematic:Hide", ()->
        api.text.textContent = "Schematic"
        Tween b, 1, 0.6, tickBG
        Tween r, 2, 1, tickRotation
        Tween -1, 1, 1.1, tickDash
      
      Reaction "Schematic:Show", ()->
        api.text.textContent = "Activate"
        Tween b, 0, 0.4, tickBG
        if Math.abs(r%1) < 0.01
          Tween.cancel tickRotation
          tickRotation r = 0
        else
          t = if r%1 < 0.5 then r%1 else r%1-1
          Tween t, 0, 0.5, tickRotation
        Tween.cancel tickDash
        tickDash 1
    
    click: ()->
      Action "Schematic:Toggle"
