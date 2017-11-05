Take ["Action", "Settings"], (Action, Settings)->
  
  Settings.addSetting "switch",
    name: "Flow Arrows"
    value: true
    update: (active)-> Action if active then "FlowArrows:Show" else "FlowArrows:Hide"
