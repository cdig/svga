do ()->
  
  # Look for an <object> that contains this SVGA
  target = null
  for o in window.parent.document.querySelectorAll "object"
    if o.contentDocument is document
      target = o
      break
  
  # If we haven't found a containing <object>, then we must be running standalone
  target ?= document.body
  
  Make "ParentObject", target
