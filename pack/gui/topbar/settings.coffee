Take ["Action", "Reaction", "SVG", "TopBar", "Tween"], (Action, Reaction, SVG, TopBar, Tween)->
  b = 0
  tickBG = (v)-> SVG.styles api.bg, "fill-opacity":b=v

  TopBar "Settings", api =
    setup: ()->
      SVG.styles api.bg, fill: "hsl(220, 50%, 60%)"
      tickBG 0
      
      Reaction "Settings:Show", ()->
        Tween b, 1, 0.6, tickBG
      
      Reaction "Settings:Hide", ()->
        Tween b, 0, 0.4, tickBG
    
    click: ()->
      Action "Settings:Toggle"
