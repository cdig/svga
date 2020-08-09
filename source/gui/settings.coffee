Take ["Action", "Ease", "GUI", "Input", "Mode", "Registry", "Resize", "Scope", "SVG", "WrapText", "ControlReady"], (Action, Ease, GUI, Input, Mode, Registry, Resize, Scope, SVG, WrapText)->

  panelWidth = GUI.Panel.itemWidth + GUI.Panel.panelPad * 2
  panelHeight = 0
  innerHeight = 0

  elm = SVG.create "g", GUI.elm

  # Meta Info

  metaBoxHeight = 20

  metaBoxElm = SVG.create "g", elm
  metaBox = Scope metaBoxElm

  metaBoxRect = SVG.create "rect", metaBoxElm,
    width: panelWidth
    fill: GUI.Colors.bg.d
    rx: GUI.Panel.panelBorderRadius

  titleLines = Mode.get("meta")?.title
  titleLines = [] unless titleLines?
  if not Mode.embed and titleLines.length is 0
    titleString = document.title.replace("| ", "").replace("LunchBox Sessions", "")
    titleLines = WrapText titleString, 28

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
    rx: GUI.Panel.panelBorderRadius
    fill: GUI.Colors.bg.l

  items = SVG.create "g", elm,
    transform: "translate(#{GUI.Panel.panelPad},#{GUI.Panel.panelPad})"

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

  input = Input close, click: (e, state)->
    input.resetState() # Hack to fix https://github.com/cdig/svga/issues/154
    Action "Settings:Hide"

  Settings = Scope elm, ()->
    addSetting: (type, props)->
      instance = Scope SVG.create "g", items
      builder = Registry.get "SettingType", type
      scope = builder instance.element, props
      instance.y = innerHeight
      innerHeight += GUI.Panel.unit + GUI.Panel.itemMargin
      panelHeight = innerHeight + GUI.Panel.panelPad*2 - GUI.Panel.itemMargin
      SVG.attrs bg, height: panelHeight
      SVG.attrs metaBoxRect, y: -panelHeight, height: panelHeight + metaBoxHeight
      metaBox.y = panelHeight
      return scope

  Settings.hide 0

  Make "Settings", Settings

  Resize (info)->
    Settings.scale = Ease.linear info.window.w, 0, panelWidth + GUI.Panel.panelMargin*2, 0, 1
    Settings.x = info.window.w/2 - panelWidth/2 * Settings.scale
    Settings.y = Ease.linear info.window.h, panelHeight, 1000, -10, 300, false
