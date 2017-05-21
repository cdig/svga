Take ["GUI", "Registry", "SVG"], ({ControlPanel:GUI}, Registry, SVG)->
  Registry.set "Control", "divider", (elm, props)->
    
    g = SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      height: GUI.pad*2
      rx: 2
      fill: "hsl(227, 45%, 24%)"
    
    height = GUI.pad * 4
    
    return scope =
      getPreferredSize: (size, view, vertical)-> w:0, h:0
      
      resize: (size, view, vertical)->
        if @alpha = vertical
          width = size.w - GUI.pad*2
          SVG.attrs g, width: width
          w:width, h:height
        else
          w:0, h:0
