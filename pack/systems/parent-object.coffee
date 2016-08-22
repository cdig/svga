do ()->
  target = null
  for o in window.parent.document.querySelectorAll "object"
    if o.contentDocument is document
      target = o
      break
  
  target ?= document.body
  Make "ParentObject", target
