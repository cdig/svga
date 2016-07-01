# This is sugar for Symbol developers, so that they don't have to take a dozen things

Take ["Animation","ControlPanel","Ease","FlowArrows","HydraulicPressure","Mask","PointerInput","Symbol","TopBar"],
(      Animation , ControlPanel , Ease , FlowArrows , HydraulicPressure , Mask , PointerInput , Symbol , TopBar)->
  
  SVGA =
    animation: Animation
    arrows: FlowArrows
    control: ControlPanel.addControl
    ease: Ease
    input: PointerInput
    mask: Mask
    pressure: HydraulicPressure
    symbol: Symbol
    topbar: TopBar.init
  
  # This is sugar for legacy Symbols, so that they don't have to update their takes right away
  Make "SVGAnimation", SVGAnimation = Animation
  Make "SVGMask", SVGMask = Mask
  
  # Ready, Aim, Fire!
  Make "SVGA", SVGA
