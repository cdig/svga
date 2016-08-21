Take ["GUI", "Reaction", "Resize", "Scope", "SVG", "ScopeReady"], (GUI, Reaction, Resize, Scope, SVG)->
  
  g = Scope SVG.create "g", GUI.elm
  g.alpha = 0
  
  sliders = Scope SVG.create "g", g.element, "text-anchor": "middle"
  sliders.x = -128

  Resize ()->
    g.x = window.innerWidth/2
  
  Reaction "Settings:Show", ()-> g.show()
  Reaction "Settings:Hide", ()-> g.hide()
