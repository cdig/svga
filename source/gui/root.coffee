Take ["Reaction", "SVG", "SceneReady"], (Reaction, SVG)->
  
  Reaction "Root:Show", ()-> SVG.root._scope.show .7
  Reaction "Root:Hide", ()-> SVG.root._scope.hide .3
