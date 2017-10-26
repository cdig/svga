Take ["Action", "GUI", "Input", "Reaction", "Resize", "Scope", "SVG", "ScopeReady"], (Action, GUI, Input, Reaction, Resize, Scope, SVG)->
  
  elm = SVG.create "g", GUI.elm, ui: true
  scope = Scope elm
  
  bg = SVG.create "rect", elm,
    x: GUI.ControlPanel.panelMargin
    y: GUI.ControlPanel.panelMargin
    width: 72
    height: 30
    rx: 4
    fill: "hsl(220, 45%, 45%)"
    
  label = SVG.create "text", elm,
    textContent: "Settings"
    x: 36 + GUI.ControlPanel.panelMargin
    y: 25
    fontSize: 16
    textAnchor: "middle"
    fill: "hsl(220, 10%, 92%)"
  
  Input elm, click: ()-> Action "Settings:Toggle"
  
  Reaction "Settings:Hide", ()-> SVG.attrs label, textContent: "Settings"
  Reaction "Settings:Show", ()-> SVG.attrs label, textContent: "Back"
