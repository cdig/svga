Take ["Action", "DOOM", "GUI", "Input", "Mode", "Panel", "Scope", "SVG", "ScopeReady"], (Action, DOOM, GUI, Input, Mode, Panel, Scope, SVG)->

  return unless Mode.settings

  # Eventually, the settings button at the top should be part of an HTML-based HUD so that we don't need all this nonsense

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
    fill: GUI.Colors.bg.l

  label = SVG.create "text", elm,
    textContent: "Settings"
    x: width/2
    y: height * 0.7
    fontSize: 14
    textAnchor: "middle"
    fill: "hsl(220, 10%, 92%)"

  Input elm, click: ()->

    title = Mode.get("meta")?.title
    if not title? and not Mode.embed
      title = document.title.replace("| ", "").replace("LunchBox Sessions", "")

    if infoLines = Mode.get("meta")?.info
      info = ("<p>#{line}</p>" for line in infoLines).join ""

    panel = Panel "settings", """
      <div settings-controls></div>
      <h3 settings-title>#{title}</h3>
      <div settings-info>#{info}</div>
      <small settings-copyright>© CD Industrial Group Inc.</small>
    """

    DOOM.append panel.querySelector("[settings-controls]"), controls


  controls = DOOM.create "div", null

  Make "Settings", Settings =
    addSetting: (type, props)->
      elm = DOOM.create "svg", controls
      instance = Scope SVG.create "g", elm
      builder = Take "Settings#{type}"
      scope = builder instance.element, props
      return scope
