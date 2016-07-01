Take ["Action","ControlPanel","Dispatch","Ease","Global","FlowArrows","HydraulicPressure","Mask","Reaction","Symbol","TopBar"],
(      Action , ControlPanel , Dispatch , Ease , Global , FlowArrows , HydraulicPressure , Mask , Reaction , Symbol , TopBar)->

  # Deprecations
  Make "SVGAnimation", ()-> throw "SVGAnimation is no longer a thing. Remove SVGAnimation from your Takes, and delete the word 'SVGAnimation' from your code. Stuff should work."
  Make "SVGMask", ()-> throw "SVGMask is no longer a thing. Please Take \"SVGA\" and use SVGA.Mask instead."

  # This is sugar for Symbol developers, so that they don't have to Take all these things
  Make "SVGA", SVGA =
    Action: Action
    Arrows: FlowArrows
    Control: ControlPanel
    Dispatch: Dispatch
    Ease: Ease
    Global: Global
    Mask: Mask
    Pressure: HydraulicPressure
    Reaction: Reaction
    Symbol: Symbol
    TopBar: TopBar
