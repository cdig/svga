Take ["Action", "GUI", "Input", "Mode", "Reaction", "Scope", "SVG", "ScopeReady"], (Action, GUI, Input, Mode, Reaction, Scope, SVG)->
  
  return unless Mode.settings
  
  elm = SVG.create "g", GUI.elm, ui: true
  scope = Scope elm
  
  scope.x = GUI.ControlPanel.panelMargin
  scope.y = GUI.ControlPanel.panelMargin
  
  width = 60
  height = 22
  
  hit = SVG.create "rect", elm,
    x: -GUI.ControlPanel.panelMargin
    y: -GUI.ControlPanel.panelMargin
    width: width + 16
    height: height + 16
    fill: "transparent"
  
  bg = SVG.create "rect", elm,
    width: width
    height: height
    rx: 3
    fill: "hsl(220, 45%, 45%)"
    
  label = SVG.create "text", elm,
    textContent: "Settings"
    x: width/2
    y: height * 0.7
    fontSize: 14
    textAnchor: "middle"
    fill: "hsl(220, 10%, 92%)"
  
  Input elm, click: ()-> Action "Settings:Toggle"
