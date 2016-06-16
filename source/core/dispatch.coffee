Make "Dispatch", Dispatch = (node, name, childrenProp = "children")->
  node[name]?()
  Dispatch child, name, childrenProp for child in node[childrenProp]
