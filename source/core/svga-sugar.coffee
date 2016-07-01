Take ["Action","ControlPanel","Dispatch","Ease","FlowArrows","HydraulicPressure","Mask","PointerInput","Reaction","Symbol","TopBar"],
(      Action , ControlPanel , Dispatch , Ease , FlowArrows , HydraulicPressure , Mask , PointerInput , Reaction , Symbol , TopBar)->
  
  # Deprecations
  Make "SVGAnimation", ()-> throw "SVGAnimation is no longer a thing. Remove SVGAnimation from your Takes, and delete the word 'SVGAnimation' from your code. Stuff should work."
  Make "SVGMask", ()-> throw "SVGMask is no longer a thing. Please Take \"SVGA\" and use SVGA.mask instead."
  
  # This is sugar for Symbol developers, so that they don't have to Take all these things
  Make "SVGA", SVGA =
    action: Action
    arrows: FlowArrows
    control: ControlPanel.addControl
    dispatch: Dispatch
    ease: Ease
    input: PointerInput
    mask: Mask
    pressure: HydraulicPressure
    reaction: Reaction
    symbol: Symbol
    topbar: TopBar.init
