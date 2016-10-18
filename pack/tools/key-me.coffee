# KeyMe is a quick way to add keyboard actions without having to manage events.
# It also exposes a nice map of currently pressed keys with the "pressing" property.
# You can add handlers for "any"-key presses/releases, too.
# And it automatically circumvents the key repeat rate, so you only get one call per press. Presto!
# Hey, maybe also does shortcuts (aka: chords) too? Woo!
# Note — shortcuts only work with 1 modifier. Command-g, perfect. Command-shift-g, no.


do ()->
  downHandlers = {}
  upHandlers = {}
  
  # Give a keyname or keycode, and an options object with props for down, up, and/or modifier
  KeyMe = (key, opts)->
    if not key? then throw new Error "You must provide a key name or code for KeyMe(key, options)"
    if typeof opts isnt "object" then throw new Error "You must provide an options object for KeyMe(key, options)"
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
    
    # NOT SURE IF WE STILL NEED THIS:
    # keyUp e if e.ctrlKey # Pressing a Command key shortcut doesn't release properly, so we need to release it now


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
  
  
  KeyNames =
    3: "cancel"
    6: "help"
    8: "back_space"
    9: "tab"
    12: "clear"
    13: "return"
    14: "enter"
    16: "shift"
    17: "control"
    18: "alt"
    19: "pause"
    20: "caps_lock"
    27: "escape"
    32: "space"
    33: "page_up"
    34: "page_down"
    35: "end"
    36: "home"
    37: "left"
    38: "up"
    39: "right"
    40: "down"
    44: "printscreen"
    45: "insert"
    46: "delete"
    48: "0"
    49: "1"
    50: "2"
    51: "3"
    52: "4"
    53: "5"
    54: "6"
    55: "7"
    56: "8"
    57: "9"
    59: "semicolon"
    61: "equals" # FF
    65: "a"
    66: "b"
    67: "c"
    68: "d"
    69: "e"
    70: "f"
    71: "g"
    72: "h"
    73: "i"
    74: "j"
    75: "k"
    76: "l"
    77: "m"
    78: "n"
    79: "o"
    80: "p"
    81: "q"
    82: "r"
    83: "s"
    84: "t"
    85: "u"
    86: "v"
    87: "w"
    88: "x"
    89: "y"
    90: "z"
    93: "context_menu"
    96: "numpad0"
    97: "numpad1"
    98: "numpad2"
    99: "numpad3"
    100: "numpad4"
    101: "numpad5"
    102: "numpad6"
    103: "numpad7"
    104: "numpad8"
    105: "numpad9"
    106: "multiply"
    107: "add"
    108: "separator"
    109: "subtract"
    110: "decimal"
    111: "divide"
    112: "f1"
    113: "f2"
    114: "f3"
    115: "f4"
    116: "f5"
    117: "f6"
    118: "f7"
    119: "f8"
    120: "f9"
    121: "f10"
    122: "f11"
    123: "f12"
    124: "f13"
    125: "f14"
    126: "f15"
    127: "f16"
    128: "f17"
    129: "f18"
    130: "f19"
    131: "f20"
    132: "f21"
    133: "f22"
    134: "f23"
    135: "f24"
    144: "num_lock"
    145: "scroll_lock"
    173: "minus" # FF
    187: "equals" # Safari/Chrome
    188: "comma"
    189: "minus" # Safari/Chrome
    190: "period"
    191: "slash"
    192: "back_quote"
    219: "open_bracket"
    220: "back_slash"
    221: "close_bracket"
    222: "quote"
    224: "meta"
