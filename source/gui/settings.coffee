Take ["Action", "GUI", "Input", "Reaction", "Registry", "Resize", "Scope", "SVG", "ControlReady"], (Action, GUI, Input, Reaction, Registry, Resize, Scope, SVG)->
  
  height = 0
  panelWidth = GUI.Settings.itemWidth + GUI.Settings.panelPad * 2
  
  elm = SVG.create "g", GUI.elm
  
  bg = SVG.create "rect", elm,
    width: panelWidth
    rx: GUI.Settings.panelBorderRadius
    fill: "hsl(220, 45%, 45%)"
  
  items = SVG.create "g", elm,
    transform: "translate(#{GUI.Settings.panelPad},#{GUI.Settings.panelPad})"
  
  # Close Button
  
  close = SVG.create "g", elm,
    ui: true
    transform: "translate(8,8)"

  closeCircle = SVG.create "circle", close,
    r: 16
    fill: "#F00"
  
  closeText = SVG.create "text", close,
    dy: 4
    textContent: "x"
    textAnchor: "middle"
    fill: "#FFF"
  
  # Finish Setup
  
  Input close, click: ()-> Action "Settings:Toggle"
  
  Settings = Scope elm, ()->
    addSetting: (type, props)->
      instance = Scope SVG.create "g", items
      builder = Registry.get "SettingType", type
      builder instance.element, props
      instance.y = height
      height += GUI.Settings.unit + GUI.Settings.itemMargin
      SVG.attrs bg, height: height + GUI.Settings.panelPad*2 - GUI.Settings.itemMargin
  
  Settings.hide 0
  
  Make "Settings", Settings
  
  Resize ()->
    svgRect = SVG.svg.getBoundingClientRect()
    Settings.x = svgRect.width/2 - panelWidth/2
    Settings.y = 60
  
  Reaction "Settings:Show", ()-> Settings.show .3
  Reaction "Settings:Hide", ()-> Settings.hide .3
