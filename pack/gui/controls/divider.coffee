Take ["GUI", "Registry", "SVG"], ({ControlPanel:GUI}, Registry, SVG)->
  Registry.set "Control", "divider", (elm, props)->
    
    g = SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      width: GUI.width - GUI.pad*2
      height: GUI.pad*2
      rx: 2
      fill: "hsl(227, 45%, 24%)"
    
    resize = (size, view, vertical)->
      if @alpha = vertical
        w:GUI.width, h:GUI.pad * 4
      else
        w:0, h:0
    
    return scope =
      resize: resize
      getPreferredSize: resize
