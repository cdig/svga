Take ["Reaction", "SVG", "SceneReady"], (Reaction, SVG)->
  
  Reaction "Root:Show", ()-> SVG.root._scope.show .5
  Reaction "Root:Hide", ()-> SVG.root._scope.hide .5, .2
