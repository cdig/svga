Take ["Reaction", "SceneReady"], (Reaction)->
  
  root = document.querySelector "#root"
  
  Reaction "Root:Show", ()-> root._scope.show 1
  Reaction "Root:Hide", ()-> root._scope.hide 1
