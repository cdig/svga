Take ["Dev", "AllReady"], (Dev)->
  
  return unless Dev
  
  nodes = Array.prototype.slice.call document.querySelectorAll "#root [id]"
  
  for elm in nodes
    elm.removeAttribute "id"
