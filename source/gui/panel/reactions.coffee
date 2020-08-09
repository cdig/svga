Take ["Action", "ControlPanel", "Panel", "Reaction", "SVG", "SVGReady"], (Action, ControlPanel, Panel, Reaction, SVG)->

  # It'd be better if this logic were in some sort of state machine with purview
  # over the entire GUI, but things aren't complex enough to warrant that yet.
  # Something like a router, I guess.

  Reaction "Panel:Hide", ()->
    Panel.hide()
    ControlPanel.show .5
    SVG.root._scope.show .5

  Reaction "Panel:Show", ()->
    Panel.show()
    ControlPanel.hide .5
    SVG.root._scope.hide .5, .2
