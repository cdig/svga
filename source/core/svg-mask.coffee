#the root is the svg element at the root
#the parent is the parent of the masked Element
#mask insance is what you're using to mask
#masked instance is the element a mask is applied to
#mask name is the name of the mask; make sure this is distinct
getParentInverseTransform = (element, currentTransform)->
  if element.nodeName is "svg"
    return currentTransform
  inversion = invertSVGMatrix(element.getAttribute("transform"))
  currentTransform = "#{currentTransform} #{inversion}"
  getParentInverseTransform(element.parentNode, currentTransform)

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

  invertMatrix = getParentInverseTransform(maskedElement.parentNode, "")#invertSVGMatrix(maskedElement.getAttribute("transform"))
  origMatrix = maskElement.getAttribute("transform")
  transString = "#{origMatrix} #{invertMatrix} "
  maskElement.setAttribute('transform', transString)

  origStyle = maskedElement.getAttribute('style')
  if origStyle?
    newStyle = origStyle + "; mask: url(##{maskName});"
  else
    newStyle = "mask: url(##{maskName});"
  maskedElement.setAttribute('transform', "matrix(1, 0, 0, 1, 0 0)")
  maskedInstance.transform.setBaseTransform()
  maskedParent.setAttribute("style", newStyle)


