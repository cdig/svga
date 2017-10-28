Take ["Action", "Settings"], (Action, Settings)->
  
  Settings.addSetting "switch",
    name: "Highlights"
    value: true
    update: (active)-> Action "Highlights:Set", active
