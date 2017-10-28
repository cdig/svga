Take ["Action", "Settings"], (Action, Settings)->
  
  Settings.addSetting "slider",
    name: "Background"
    value: .7
    snaps: [.7]
    update: (v)-> Action "Background:Lightness", v
