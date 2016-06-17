Take ["Action", "Dispatch", "Global", "Reaction", "root"],
(      Action ,  Dispatch ,  Global ,  Reaction ,  root)->
  
  Reaction "toggleAnimateMode", ()->
    Action if Global.animateMode then "schematicMode" else "animateMode"
  
  Reaction "animateMode", ()->
    Global.animateMode = true
    Dispatch root, "animateMode"
  
  Reaction "schematicMode", ()->
    Global.animateMode = false
    Dispatch root, "schematicMode"
