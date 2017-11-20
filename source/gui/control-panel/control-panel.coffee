Take ["HUD", "ControlPanelLayout", "Gradient", "GUI", "Mode", "Reaction", "SVG", "Scope", "TRS", "ControlReady"], (HUD, ControlPanelLayout, Gradient, GUI, Mode, Reaction, SVG, Scope, TRS, ControlReady)->
  
  # Aliases
  CP = GUI.ControlPanel
  config = Mode.controlPanel ?= {}
  
  # State
  showing = false
  groups = []
  columnElms = []
  
  # Elements
  
  panelElm = SVG.create "g", GUI.elm,
    xControls: ""
    fontSize: 16
    textAnchor: "middle"
  
  panelBg = SVG.create "rect", panelElm,
    xPanelBg: ""
    rx: CP.panelBorderRadius
    fill: "hsl(220, 45%, 45%)"
  
  columnsElm = SVG.create "g", panelElm,
    xColumns: ""
    transform: "translate(#{CP.panelPadding},#{CP.panelPadding})"
  
  
  getColumnElm = (index)->
    columnElms[index] ?= SVG.create "g", columnsElm
  
  
  Take "SceneReady", ()->
    if !showing
      # It'd be simpler to just not add the CP unless we need it,
      # rather than what we're doing here (remove it if it's unused).
      # But we need to do it this way to avoid an IE bug.
      GUI.elm.removeChild panelElm
  
  
  Make "ControlPanel", ControlPanel = Scope panelElm, ()->
    registerGroup: (group)->
      groups.push group
    
    createItemElement: (parent)->
      showing = true
      SVG.create "g", parent
    
    computeLayout: (vertical, totalAvailableSpace)->
      marginedSpace =
        w: totalAvailableSpace.w - CP.panelMargin*2
        h: totalAvailableSpace.h - CP.panelMargin*2
      
      [innerPanelSize, layout] = if vertical
        ControlPanelLayout.vertical groups, marginedSpace
      else
        ControlPanelLayout.horizontal groups, marginedSpace
      
      # If the panel is still way the hell too big, scale down
      scale = if vertical and (innerPanelSize.w > marginedSpace.w/2 or innerPanelSize.h > marginedSpace.h)
        Math.max 0.8, Math.min marginedSpace.w / innerPanelSize.w / 2, marginedSpace.h / innerPanelSize.h
      else if !vertical and (innerPanelSize.w > marginedSpace.w or innerPanelSize.h > marginedSpace.h/2)
        Math.max 0.8, Math.min marginedSpace.w / innerPanelSize.w, marginedSpace.h / innerPanelSize.h / 2
      else
        1
      
      outerPanelSize =
        w: innerPanelSize.w * scale + CP.panelMargin*2
        h: innerPanelSize.h * scale + CP.panelMargin*2
      
      # How much of the available content space does the panel use up?
      consumedSpace = w: 0, h: 0
      consumedSpace.w = outerPanelSize.w if showing and vertical
      consumedSpace.h = outerPanelSize.h if showing and not vertical
      
      return panelInfo =
        showing: showing
        vertical: vertical
        consumedSpace: consumedSpace
        innerPanelSize: innerPanelSize
        outerPanelSize: outerPanelSize
        scale: scale
        layout: layout
    
    applyLayout: (resizeInfo, totalAvailableSpace)->
      return unless resizeInfo.panelInfo.showing
      
      # Now that we know which layout we're using, apply it to the SVG
      ControlPanelLayout.applyLayout resizeInfo.panelInfo.layout, getColumnElm
      
      if resizeInfo.panelInfo.vertical
        ControlPanel.x = Math.round totalAvailableSpace.w - resizeInfo.panelInfo.outerPanelSize.w + CP.panelMargin
        ControlPanel.y = Math.round totalAvailableSpace.h/2 - resizeInfo.panelInfo.outerPanelSize.h/2 + CP.panelMargin
      else
        ControlPanel.x = Math.round totalAvailableSpace.w/2 - resizeInfo.panelInfo.outerPanelSize.w/2 + CP.panelMargin
        ControlPanel.y = Math.round totalAvailableSpace.h - resizeInfo.panelInfo.outerPanelSize.h + CP.panelMargin
      
      ControlPanel.scale = resizeInfo.panelInfo.scale
      
      # Apply the final size to our background elm
      SVG.attrs panelBg,
        width: resizeInfo.panelInfo.innerPanelSize.w
        height: resizeInfo.panelInfo.innerPanelSize.h
  
  
  Reaction "ControlPanel:Show", ()-> ControlPanel.show .5
  Reaction "ControlPanel:Hide", ()-> ControlPanel.hide .5
