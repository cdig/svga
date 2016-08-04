Take ["Control", "GUI", "SVG"], (Control, {ControlPanel:GUI}, SVG)->
  Control "divider", (elm, props)->
    
    g = SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      width: GUI.width - GUI.pad*2
      height: GUI.pad*3
      fill: "white"
      rx: GUI.pad
    
    setColor = (l)-> SVG.attrs g, fill: "hsl(220, 16%, #{l*100}%)"
    setColor 0.24
    
    return scope =
      attach: (props)-> # noop
      getPreferredSize: ()-> w:GUI.width, h:GUI.pad * 5
      resize: ({w:w, h:h})-> # noop
