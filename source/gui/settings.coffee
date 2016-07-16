Take ["Reaction", "root", "Tween1"], (Reaction, root, Tween1)->
  
  tick = (v)-> root.mainStage.alpha = v
  
  Reaction "Settings:Show", ()->
    Tween1 root.mainStage.alpha, 0, 0.7, tick
  
  Reaction "Settings:Hide", ()->
    Tween1 root.mainStage.alpha, 1, 0.7, tick
