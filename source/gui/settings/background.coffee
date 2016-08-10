Take ["Action", "Config", "Reaction", "SVG", "DOMContentLoaded"], (Action, Config, Reaction, SVG)->
  
  
  # This bogus lets us workaround a bug in Chrome,
  # by changing the BG of the <object> that loads us
  # rather than our own <svg> element.
  target = null
  for o in window.parent.document.querySelectorAll "object"
    if o.contentDocument = document
      target = o
      break
  
  # Set to a specific color
  if typeof Config.background is "string"
    SVG.style target, "background-color", Config.background
  
  # Allow adjustment, default to grey
  else if Config.background
    setBackground = (v)->
      c = "hsl(227, 5%, #{v*100}%)"
      SVG.style target, "background-color", c
    
    Reaction "Background:Set", setBackground
    
    Take "ScopeReady", ()->
      Action "Background:Set", .70
  
  # No background
  else
    SVG.style target, "background-color", "transparent"
