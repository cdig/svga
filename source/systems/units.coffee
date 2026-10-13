# Units
# use Units.pick(imperialValue, siValue)

Take ["Action", "Mode", "ParentData", "SVG", "SVGReady"], (Action, Mode, ParentData, SVG)->
  units = null
  cleanId = (elm)-> elm.id.replace /_FL/g, ""
  elms = (elm for elm in SVG.root.querySelectorAll "[id]" when /_(imperial|si)$/.test cleanId elm)

  set = (val)->
    return if val is units or val not in ["imperial", "si"]
    units = val
    elm.style.display = (if cleanId(elm).endsWith "_#{units}" then "" else "none") for elm in elms
    Action "Units:Set", units

  Make "Units",
    get: ()-> units
    pick: (imperial, si)-> if units is "si" then si else imperial
    set: set

  # Mode.get only reaches for ParentData when we're embedded — on its own, ParentData isn't a real object.
  set Mode.get("units") or new URLSearchParams(location.search).get("units") or document.documentElement.getAttribute("units") or "imperial"
  ParentData.listen ((inbox)-> set inbox.units) if Mode.embed

  # Symbols are built well after SVGReady, so repeat ourselves once everything is listening.
  Take "AllReady", ()-> Action "Units:Set", units
