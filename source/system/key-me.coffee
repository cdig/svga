# KeyMe is a quick way to add keyboard actions without having to manage events.
# It also exposes a nice map of currently pressed keys with the "pressing" property.
# You can add handlers for "any"-key presses/releases, too.
# And it automatically circumvents the key repeat rate, so you only get one call per press. Presto!
# Hey, maybe also does shortcuts (aka: chords) too? Woo!
# Note — shortcuts only work with 1 modifier. Command-g, perfect. Command-shift-g, no.


Take ["KeyNames"], (KeyNames)->
  downHandlers = {}
  upHandlers = {}
  
  # Give a keyname or keycode, and an options object with props for down, up, and/or modifier
  KeyMe = (key, opts)->
    if not key? then throw "You must provide a key name or code for KeyMe(key, options)"
    if typeof opts isnt "object" then throw "You must provide an options object for KeyMe(key, options)"
    name = if typeof key is "string" then key else KeyNames[key]
    actionize opts.down, opts.up, name, opts.modifier
  
  # Register a down/up handler for when you press any key
  KeyMe.any =	  	 (down, up)->                 actionize down, up, "any"
  
  # Register a down/up handler for a given character
  KeyMe.char =     (char, down, up)->           actionize down, up, char
  
  # Register a down/up handler for a given modifier+character
  KeyMe.shortcut = (modifier, char, down, up)-> actionize down, up, char, modifier
  
  KeyMe.pressing = {}
  KeyMe.lastPressed = null
  
  
  actionize = (down, up, name, modifier)->
    (downHandlers[name] ?= []).push callback: down, modifier: modifier if down?
    (upHandlers[name] ?= []).push callback: up, modifier: modifier if up?
  
  
  keyDown = (e)->
    code = e.which or e.keyCode
    name = KeyNames[code]
    return unless name?
    return if KeyMe.pressing[name] # Swallow key repeat
    
    KeyMe.pressing[name] = true
    KeyMe.lastPressed =
      name: name
      code: code
    
    handleKey name, e, downHandlers
    
    # NOT SURE IF WE STILL NEED THIS
    # Pressing a Command key shortcut doesn't release properly, so we need to release it now
    # keyUp e if e.ctrlKey


  keyUp = (e)->
    code = e.keyCode
    name = KeyNames[code]
    return unless name?
    
    delete KeyMe.pressing[name]
    
    handleKey name, e, upHandlers

  
  handleKey = (name, e, handlers)->
    modifier = getModifier e
    modifier = null if name is modifier
    
    runCallbacks handlers.any, modifier
    runCallbacks handlers[name], modifier
  

  getModifier = (e)->
    return "meta"  if e.ctrlKey
    return "alt"   if e.altKey
    return "shift" if e.shiftKey # If we support shift, then uppercase chars might not work — need to test
  
  
  runCallbacks = (callbacks, modifier)->
    if callbacks?
      for command in callbacks when command.modifier is modifier
        command.callback()
  
  window.addEventListener "keydown", keyDown
  window.addEventListener "keyup", keyUp
  window.addEventListener "blur", ()-> KeyMe.pressing = {}
  
  Make "KeyMe", KeyMe
