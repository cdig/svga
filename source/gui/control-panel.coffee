Take ["PointerInput", "Resize", "SVG"], (PointerInput, Resize, SVG)->
  topbarHeight = 48
  minGridSize = 50
  minColumns = 3
  gridPad = 2
  iconPad = 4
  
  supportedTypes = ["button", "gui"]
  defs = {}
  elements = []
  
  controlPanel = SVG.create "g", SVG.root, class: "ControlPanel"
  panel = SVG.create "rect", controlPanel, class: "Panel"
  
  
  Resize resize = ()->
    goalW = window.innerWidth * .2
    columns = Math.max minColumns, Math.floor goalW / minGridSize
    gridSize = Math.ceil goalW / columns
    
    SVG.attr panel, "width", panelW = columns * (gridSize + gridPad) # the 1 excesss unit of gridPad will be used below...
    SVG.attr panel, "height", window.innerHeight - topbarHeight
    SVG.move controlPanel, window.innerWidth - panelW + gridPad, topbarHeight # ...to avoid flickering on the right edge due to rounding errors
    
    # These are measured in grid units, not pixels
    offsetX = 0
    offsetY = 0
    rowHeight = 0
    
    for element in elements
      scope = element.scope
      
      if offsetX + scope.width > columns
        offsetY += rowHeight
        rowHeight = 0
        offsetX = 0
      
      SVG.move element.g, offsetX * (gridSize + gridPad), offsetY * (gridSize + gridPad)
      
      switch element.type
        when "button"
          SVG.attrs scope.bg, width: (gridSize + gridPad) * scope.width - gridPad, height: (gridSize + gridPad) * scope.height - gridPad
          SVG.attrs scope.icon, width: gridSize - iconPad*2, height: gridSize - iconPad*2, x: iconPad, y: iconPad
          textRect = scope.text.getBoundingClientRect()
          SVG.move scope.text, gridSize + iconPad*2, gridSize * scope.height/2 + textRect.height/2
        when "gui"
          null # noop
      
      scope.resize? gridSize, gridPad, iconPad
      
      rowHeight = Math.max rowHeight, scope.height
      offsetX += scope.width
      
  
  construct = (i, name, type, fn)->
    g = SVG.create "g", controlPanel, class: "#{type} ui Element"
    scope = fn g
    switch type
      when "button"
        scope.width = 3
        scope.height = 1
        scope.bg = SVG.create "rect", g, class: "BG"
        scope.icon = SVG.create "use", g, "xlink:href": "#" + name
        scope.text = SVG.create "text", g, "font-family": "Lato", "font-size": 14, fill: "#FFF"
        scope.text.textContent = name.toUpperCase()
        PointerInput.addClick g, scope.click if scope.click?
      when "gui"
        null # noop
    scope.setup?()
    elements.push g: g, i: i, name:name, scope: scope, type: type

  
  Make "ControlPanel", ControlPanel =
    define: (type, name, fn)->
      console.log "Warning: Unknown ControlPanel.define() type: '#{type}'" unless type in supportedTypes
      defs[name] = fn:fn, type:type
    
    # This will be called by one of the symbols (probably root) during its setup
    init: (elementNames...)->
      for name, i in elementNames
        if (def = defs[name])?
          construct i, name, def.type, def.fn
        else
          console.log "Warning: Unknown ControlPanel.init() name: '#{name}'"
      resize()
      
