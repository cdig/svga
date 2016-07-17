Take ["Reaction", "root", "Tween1"], (Reaction, root, Tween1)->
  
  return unless root.mainStage?
  
  tick = (v)-> root.mainStage.alpha = v
  
  Reaction "MainStage:Show", ()->
    Tween1 root.mainStage.alpha, 1, 0.7, tick
  
  Reaction "MainStage:Hide", ()->
    Tween1 root.mainStage.alpha, 0, 0.7, tick
