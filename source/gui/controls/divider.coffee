Take ["GUI", "Registry", "SVG"], ({ControlPanel:GUI}, Registry, SVG)->
  Registry.set "Control", "divider", (elm, props)->
    throw "Error: Control.divider() has been removed."
