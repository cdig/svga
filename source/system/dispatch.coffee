Take [], ()->
  Make "Dispatch", (node, fn, sub = "children")->
    if typeof fn is "string"
      dispatchString node, fn, sub
    else
      dispatchFn node, fn, sub
  
  dispatchString = (node, fn, sub)->
    node[fn]?()
    dispatchString child, fn, sub for child in node[sub]
  
  dispatchFn = (node, fn, sub)->
    fn node
    dispatchFn child, fn, sub for child in node[sub]
