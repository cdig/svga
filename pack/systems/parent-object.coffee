do ()->
  target = null
  for o in window.parent.document.querySelectorAll "object"
    if o.contentDocument is document
      target = o
      break
  
  if not target? then throw "ParentObject could not determine which <object> embedded this SVGA."
  Make "ParentObject", target
