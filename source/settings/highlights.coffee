Take ["Action", "Settings"], (Action, Settings)->
  
  Settings.addSetting "Highlights", "switch", true, (active)->
    Action "Highlights:Set", active
