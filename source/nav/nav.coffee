Take ["ControlPanel", "DynamicNav", "Mode", "ParentElement", "StaticSize", "SceneReady"], (ControlPanel, DynamicNav, Mode, ParentElement, StaticSize)->
  
  if Mode.nav
    DynamicNav()
  else
    Make "Nav", false
    StaticSize()
