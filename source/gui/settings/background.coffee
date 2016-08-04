Take ["Action", "Reaction", "SVG", "DOMContentLoaded"], (Action, Reaction, SVG)->
  
  # This bogus lets us workaround a bug in Chrome,
  # by changing the BG of the <object> that loads us
  # rather than our own <svg> element.
  target = null
  for o in window.parent.document.querySelectorAll "object"
    if o.contentDocument = document
      target = o
      break
  
  
  setBackground = (v)->
    c = "hsl(227, 5%, #{v*100}%)"
    SVG.style target, "background-color", c
      
  
  Reaction "Background:Set", setBackground
  
  Take "ScopeReady", ()->
    Action "Background:Set", .70
