Take ["HUD", "Mode", "SVGReady"], (HUD, Mode)->
  return unless Mode.dev
  
  nodeCountElm = document.querySelector "[node-count]"
  
  if nodeCountElm?
    HUD "Nodes", nodeCountElm.getAttribute("node-count"), "#0003"
