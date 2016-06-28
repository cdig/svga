#the root is the svg element at the root
#the parent is the parent of the masked Element
#mask insance is what you're using to mask
#masked instance is the element a mask is applied to
#mask name is the name of the mask; make sure this is distinct
getParentInverseTransform = (root,element, currentTransform)->
  if element.nodeName is "svg" or element.getAttribute("id") is "mainStage"
    return currentTransform
  newMatrix = root.getElement().createSVGMatrix()
  matrixString = element.getAttribute("transform")
  matches = matrixString.match(/[+-]?\d+(\.\d+)?/g)
  newMatrix.a = matches[0]
  newMatrix.b = matches[1]
  newMatrix.c = matches[2]
  newMatrix.d = matches[3]
  newMatrix.e = matches[4]
  newMatrix.f = matches[5]
  inv = newMatrix.inverse()
  inversion = "matrix(#{inv.a}, #{inv.b}, #{inv.c}, #{inv.d}, #{inv.e}, #{inv.f})"
  currentTransform = "#{currentTransform} #{inversion}"
  getParentInverseTransform(root,element.parentNode, currentTransform)

Make "SVGMask", SVGMask = (root, maskInstance, maskedInstance, maskName)->
  maskElement = maskInstance.getElement()
  maskedElement = maskedInstance.getElement()
  rootElement = root.getElement()
  mask = document.createElementNS("http://www.w3.org/2000/svg", "mask")
  mask.setAttribute("id", maskName)
  mask.setAttribute("maskContentUnits", "userSpaceOnUse")

  maskedParent = document.createElementNS("http://www.w3.org/2000/svg", "g")
  maskedParent.setAttribute('transform', maskedElement.getAttribute( 'transform'))
  maskedElement.parentNode.insertBefore(maskedParent, maskedElement)
  maskedElement.parentNode.removeChild(maskedElement)
  maskedParent.appendChild(maskedElement)


  mask.appendChild(maskElement)

  rootElement.querySelector('defs').insertBefore(mask, null)
  invertMatrix = getParentInverseTransform(root, maskedElement.parentNode, "")
  origMatrix = maskElement.getAttribute("transform")

  transString = "#{invertMatrix} #{origMatrix} "
  maskElement.setAttribute('transform', transString)

  origStyle = maskedElement.getAttribute('style')
  if origStyle?
    newStyle = origStyle + "; mask: url(##{maskName});"
  else
    newStyle = "mask: url(##{maskName});"
  maskedElement.setAttribute('transform', "matrix(1, 0, 0, 1, 0, 0)")
  maskedInstance.transform.setBaseTransform()
  maskedParent.setAttribute("style", newStyle)
