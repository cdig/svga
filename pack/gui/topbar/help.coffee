Take ["Action", "Reaction", "SVG", "TopBar", "Tween"], (Action, Reaction, SVG, TopBar, Tween)->
  b = 0
  tickBG = (v)-> SVG.styles api.bg, "fill-opacity":b=v
  
  TopBar "Help", api =
    setup: ()->
      SVG.styles api.bg, fill: "hsl(220, 50%, 60%)"
      tickBG 0
      
      Reaction "Help:Show", ()->
        Tween b, 1, 0.6, tickBG
      
      Reaction "Help:Hide", ()->
        Tween b, 0, 0.4, tickBG
    
    click: ()->
      Action "Help:Toggle"
