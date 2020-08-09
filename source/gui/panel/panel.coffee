Take ["Action", "DOOM", "GUI", "Resize", "SVG", "Scope", "ScopeReady"], (Action, DOOM, GUI, Resize, SVG, Scope)->

  foreignObject = SVG.create "foreignObject", GUI.elm
  outer = DOOM.create "div", foreignObject, id: "panel-outer"
  inner = DOOM.create "div", outer, id: "panel-inner"

  closer = DOOM.create "div", inner, id: "panel-closer"
  closer.addEventListener "click", ()-> Action "Panel:Hide"

  Resize ()->
    SVG.attrs foreignObject,
      width: window.innerWidth
      height: window.innerHeight

  Panel = (html)->
    inner.innerHTML = html
    Action "Panel:Show"
    return inner

  Panel.show = ()->
    DOOM outer, opacity: 1, pointerEvents: "auto"

  Panel.hide = ()->
    DOOM outer, opacity: 0, pointerEvents: "none"


  Panel.alert = (msg, cb)->
    Panel """
      <h3>#{msg}</h3>
      <div><button>Okay</button></div>
    """
    inner.querySelector("button").addEventListener "click", ()->
      Action "Panel:Hide"
      cb?()

  Make "Panel", Panel
