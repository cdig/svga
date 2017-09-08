Take ["Reaction", "SVG", "SceneReady"], (Reaction, SVG)->
  
  Reaction "Root:Show", ()-> SVG.root._scope.show 1
  Reaction "Root:Hide", ()-> SVG.root._scope.hide 1
