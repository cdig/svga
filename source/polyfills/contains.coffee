# This is needed because IE doesn't support Node.contains() on SVG elements. Not sure about Edge.

SVGElement.prototype.contains ?= (node)->
  while node?
    return true if this is node
    node = node.parentNode
  return false
