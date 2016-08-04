Take ["Control", "GUI", "SVG"], (Control, {ControlPanel:GUI}, SVG)->
  Control "divider", (elm, props)->
    
    g = SVG.create "rect", elm,
      x: GUI.pad
      y: GUI.pad
      width: GUI.width - GUI.pad*2
      height: GUI.pad*3
      rx: GUI.pad
      fill: "hsl(227, 45%, 24%)"
    
    return scope =
      attach: (props)-> # noop
      getPreferredSize: ()-> w:GUI.width, h:GUI.pad * 5
      resize: ({w:w, h:h, x:x, y:y}, view, vertical)->
        w:GUI.width, h:GUI.pad * 5
        # if @visible = vertical
        #   w:GUI.width, h:GUI.pad * 5
        # else
        #   w:0, h:0
