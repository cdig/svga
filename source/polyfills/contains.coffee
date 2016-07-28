# This is needed because IE doesn't support Node.contains() on SVG elements. Not sure about Edge.

SVGElement.prototype.contains ?= (root, node)->
  while node
    return true if node is root
    node = node.parentNode
  return false
