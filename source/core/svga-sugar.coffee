# This is sugar for Symbol developers, so that they don't have to take a dozen things

Take ["ControlPanel","Ease","FlowArrows","HydraulicPressure","Mask","PointerInput","Symbol","TopBar"],
(      ControlPanel , Ease , FlowArrows , HydraulicPressure , Mask , PointerInput , Symbol , TopBar)->
  
  SVGA =
    arrows: FlowArrows
    control: ControlPanel.addControl
    ease: Ease
    input: PointerInput
    mask: Mask
    pressure: HydraulicPressure
    symbol: Symbol
    topbar: TopBar.init
  
  # Deprecations
  Make "SVGAnimation", ()-> throw "SVGAnimation is no longer a thing. Remove SVGAnimation from your Takes, and delete the word 'SVGAnimation' from your code. Stuff should work."
  Make "SVGMask", ()-> throw "SVGMask is no longer a thing. Please Take \"SVGA\" and use SVGA.mask instead."
  
  # Ready, Aim, Fire!
  Make "SVGA", SVGA
