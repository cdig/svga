Take ["PointerInput", "Resize", "SVG", "TRS"], (PointerInput, Resize, SVG, TRS)->
  topBarHeight = 48
  buttonPad = 30
  iconPad = 4
  
  elements = {}
  offsetX = 0
  
  topBar = SVG.create "g", SVG.root, class: "TopBar"
  bg = SVG.create "rect", topBar, height: 48, fill: "url(#TopBarGradient)"
  SVG.createGradient "TopBarGradient", false, "#35488d", "#5175bd", "#35488d"
  container = TRS SVG.create "g", topBar, class: "Elements"
  
  resize = ()->
    SVG.attrs bg, width: window.innerWidth
    TRS.move container, window.innerWidth/2 - offsetX/2
    elm.scope.resize?() for elm in elements
  
  construct = (i, name, scope)->
    name = name.replace "TB:", ""
    scope.element = TRS SVG.create "g", container, class: "ui Element"
    scope.setup? scope.element
    elements[name] = element:scope.element, i:i, name:name, scope:scope
    Resize scope.resize if scope.resize?
    PointerInput.addClick scope.element, scope.click if scope.click?
    # setup() can disable these by setting the property to false, or providing its own values
    scope.bg ?= SVG.create "rect", scope.element, class: "BG", height: topBarHeight
    scope.icon ?= TRS SVG.clone document.getElementById(name.toLowerCase()), scope.element
    scope.text ?= TRS SVG.create "text", scope.element, "font-family": "Lato", "font-size": 14, fill: "#FFF", textContent: name.toUpperCase()
    computeLayout scope
  
  computeLayout = (scope)->
    iconRect = scope.icon.getBoundingClientRect()
    textRect = scope.text.getBoundingClientRect()
    iconScale = Math.min (topBarHeight - iconPad*2)/iconRect.width, (topBarHeight - iconPad*2)/iconRect.height
    iconX = buttonPad - topBarHeight/2 + iconRect.width*iconScale/2
    iconY = topBarHeight/2 - iconRect.height*iconScale/2
    textX = buttonPad + iconRect.width*iconScale + iconPad
    buttonWidth = textX + textRect.width + buttonPad
    TRS.abs scope.icon, x:iconX, y:iconY, scale: iconScale
    TRS.move scope.text, textX, topBarHeight/2 + textRect.height/2 - 3
    SVG.attrs scope.bg, width: buttonWidth
    TRS.move scope.element, offsetX
    offsetX += buttonWidth

  
  Make "TopBar", TopBar =
    
    # This will be called by one of the Symbols (probably root)
    init: (elementNames...)->
      
      # Elements are defined using Make()
      Take elementNames, (elementScopes...)->
        construct i, elementNames[i], scope for scope, i in elementScopes
        Resize resize
      
      # Redefine init, so that if it's called more than once we throw an error
      TopBar.init = ()-> throw "TopBar.init was called more than once."
