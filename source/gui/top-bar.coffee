Take ["PointerInput", "Resize", "SVG", "TRS"], (PointerInput, Resize, SVG, TRS)->
  topBarHeight = 48
  buttonPad = 30
  iconPad = 6
  
  definitions = {}
  instances = {}
  offsetX = 0
  instantiatedStarted = false

  topBar = SVG.create "g", SVG.root, class: "TopBar"
  bg = SVG.create "rect", topBar, height: 48, fill: "url(#TopBarGradient)"
  SVG.createGradient "TopBarGradient", false, "#35488d", "#5175bd", "#35488d"
  container = TRS SVG.create "g", topBar, class: "Elements"
  
  resize = ()->
    SVG.attrs bg, width: window.innerWidth
    TRS.move container, window.innerWidth/2 - offsetX/2
    instance.api.resize?() for instance in instances
    Make "TopBarReady" unless Take "TopBarReady"
  
  construct = (i, name, api)->
    throw "Unknown TopBar button name: #{name}" unless api?
    
    source = document.getElementById(name.toLowerCase())
    throw "TopBar icon not found for id: ##{name}" if not source?
    
    api.element = TRS SVG.create "g", container, class: "Element", ui: true
    instances[name] = element:api.element, i:i, name:name, api:api
    
    # The api can disable these by setting the property to false, or providing its own values
    api.bg ?= SVG.create "rect", api.element, class: "BG", height: topBarHeight
    api.icon ?= TRS SVG.clone source, api.element
    api.text ?= TRS SVG.create "text", api.element, "font-size": 14, fill: "#FFF", textContent: name.toUpperCase()
    
    iconRect = api.icon.getBoundingClientRect()
    textRect = api.text.getBoundingClientRect()
    iconScale = Math.min (topBarHeight - iconPad*2)/iconRect.width, (topBarHeight - iconPad*2)/iconRect.height
    iconX = buttonPad
    iconY = topBarHeight/2 - iconRect.height*iconScale/2
    textX = buttonPad + iconRect.width*iconScale + iconPad
    buttonWidth = textX + textRect.width + buttonPad
    TRS.abs api.icon, x:iconX, y:iconY, scale: iconScale
    TRS.move api.text, textX, topBarHeight/2 + textRect.height/2 - 3
    SVG.attrs api.bg, width: buttonWidth
    TRS.move api.element, offsetX
    offsetX += buttonWidth
    
    api.setup? api.element
    PointerInput.addClick api.element, api.click if api.click?
  
  
  Make "TopBar", (args...)->
    if typeof args[1] is "object"
      define args...
    else
      initialize args...

  define = (name, api)->
    if instantiatedStarted then throw "The TopBar element \"#{name}\" arrived after setup started. Please figure out a way to make it initialize faster."
    definitions[name] = api
  
  
  initialize = (names...)->
    throw "TopBar may only be called once, but you're calling it more than once." if instantiatedStarted
    instantiatedStarted = true
    construct i, name, definitions[name] for name, i in names
    Resize resize


    # else if childElm instanceof SVGUseElement
    #   id = childElm.getAttribute "xlink:href"
    #   if def = document.querySelector id
    #     clone = def.cloneNode true
    #     instance.replaceChild clone, childElm
    #     childElm = clone
    #     if childElm instanceof SVGGElement
    #       target.sub.push SVGCrawler childElm
    #   else
    #     console.log childElm
    #     throw "^ This <use> refers to id \"#{id}\", which doesn't exist."
