Take ["Action","Control","GUI","Pressure","Reaction","Resize","SVG","Scope","Tween","ScopeReady"],
(      Action , Control , GUI , Pressure , Reaction , Resize , SVG , Scope , Tween)->
  
  g = Scope SVG.create "g", GUI.elm
  g.alpha = 0
  
  sliders = Scope SVG.create "g", g.element, "text-anchor": "middle"
  sliders.x = -128

  # slider = Control
  #   name: "Background"
  #   type: "slider"
  #   parent: sliders
  #   change: (v)->
  #     Action "Background:Set", v *.7 + 0.3
  #
  # Reaction "Background:Set", (v)->
  #   slider.set (v - .3) / .7
  
  Resize ()->
    g.x = window.innerWidth/2
    g.y = GUI.TopBar.height * 2
  
  Reaction "Settings:Show", ()-> g.show()
  Reaction "Settings:Hide", ()-> g.hide()
