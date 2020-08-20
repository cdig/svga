Take ["GUI", "Mode", "Resize", "SVG", "TRS", "SVGReady"], (GUI, Mode, Resize, SVG, TRS)->

  # We're just going to disable this for now,
  # since keyboard input is not well-known
  return

  return unless Mode.nav

  g = TRS SVG.create "g", GUI.elm
  SVG.create "rect", g, x: -200, y:-30, width: 400, height: 60, rx: 30, fill: "#222", "fill-opacity": 0.9
  SVG.create "text", g, y: 22, textContent: "Click To Focus", "font-size": 20, fill: "#FFF", "text-anchor": "middle"

  show = ()-> SVG.attrs g, style: "display: block"
  hide = ()-> SVG.attrs g, style: "display: none"
  Resize ()-> TRS.abs g, x: SVG.svg.getBoundingClientRect().width/2

  window.addEventListener "focus", hide
  window.addEventListener "touchstart", hide
  window.addEventListener "blur", show

  window.focus() # Focus by default
