Take ["Action", "Settings"], (Action, Settings)->
  
  Settings.addSetting "Background", "slider", .7, (v)->
    Action "Background:Lightness", v
