do ()->
  
  # Look for an <object> that contains this SVGA
  parentElement = null
  for o in window.parent.document.querySelectorAll "object"
    if o.contentDocument is document
      parentElement = o
      break
  
  # If we haven't found a containing <object>, then we must be running standalone
  parentElement ?= document.body
  
  Make "ParentElement", parentElement
