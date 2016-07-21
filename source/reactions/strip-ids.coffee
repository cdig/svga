Take "AllReady", ()->
  
  nodes = Array.prototype.slice.call document.querySelectorAll "#root [id]"
  
  for elm in nodes
    elm.removeAttribute "id"
