Take ["Action", "GUI", "Input", "Mode", "Reaction", "Registry", "Resize", "Scope", "SVG", "ControlReady"], (Action, GUI, Input, Mode, Reaction, Registry, Resize, Scope, SVG)->
  
  height = 0
  panelWidth = GUI.Settings.itemWidth + GUI.Settings.panelPad * 2
  
  elm = SVG.create "g", GUI.elm
  
  # Meta Info
  
  metaBoxHeight = 20
  
  metaBoxElm = SVG.create "g", elm
  metaBox = Scope metaBoxElm
  
  metaBoxRect = SVG.create "rect", metaBoxElm,
    width: panelWidth
    fill: "hsl(227, 45%, 35%)"
    rx: GUI.Settings.panelBorderRadius
  
  titleLines = Mode.get("meta")?.title
  if not titleLines?
    titleLines = []
  if not Mode.embed and titleLines.length is 0
    titleString = document.title
                          .replace("| ", "")
                          .replace("LunchBox Sessions", "")
    titleLines = if titleString.length > 0 then [titleString] else []
  
  infoLines = Mode.get("meta")?.info
  infoLines = [] if not infoLines?
  
  metaBoxHeight += 10 if titleLines.length > 0 or infoLines.length > 0
  
  for line in titleLines
    SVG.create "text", metaBoxElm,
      x: panelWidth/2
      y: metaBoxHeight
      textContent: line
      textAnchor: "middle"
      fontSize: 18
      fontWeight: "bold"
      fill: "#FFF"
    metaBoxHeight += 24
  
  metaBoxHeight += 10 if titleLines.length > 0
  
  for line in infoLines
    SVG.create "text", metaBoxElm,
      x: panelWidth/2
      y: metaBoxHeight
      textContent: line
      textAnchor: "middle"
      fill: "#FFF"
    metaBoxHeight += 20
  
  metaBoxHeight += 10 if infoLines.length > 0
  
  SVG.create "text", metaBoxElm,
    x: panelWidth/2
    y: metaBoxHeight
    textContent: "© CD Industrial Group Inc."
    textAnchor: "middle"
    fontSize: "12"
    fill: "#FFF"
  
  metaBoxHeight += 10
    
  # Main Settings Panel
  
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
  
  closeX = SVG.create "path", close,
    d: "M-6,-6 L6,6 M6,-6 L-6,6"
    strokeWidth: 3
    strokeLinecap: "round"
    stroke: "#FFF"
  
  # Finish Setup
  
  Input close, click: ()-> Action "Settings:Toggle"
  
  Settings = Scope elm, ()->
    addSetting: (type, props)->
      instance = Scope SVG.create "g", items
      builder = Registry.get "SettingType", type
      builder instance.element, props
      instance.y = height
      height += GUI.Settings.unit + GUI.Settings.itemMargin
      bgHeight = height + GUI.Settings.panelPad*2 - GUI.Settings.itemMargin
      SVG.attrs bg, height: bgHeight
      SVG.attrs metaBoxRect, y: -bgHeight, height: bgHeight + metaBoxHeight
      metaBox.y = bgHeight
  
  Settings.hide 0
  
  Make "Settings", Settings
  
  Resize ()->
    svgRect = SVG.svg.getBoundingClientRect()
    Settings.x = svgRect.width/2 - panelWidth/2
    Settings.y = 60
  
  Reaction "Settings:Show", ()-> Settings.show .3
  Reaction "Settings:Hide", ()-> Settings.hide .3
