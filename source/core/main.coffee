Take ["Registry", "Scene", "SVG"], (Registry, Scene, SVG)->
  
  # This is the very first code that changes the DOM. It crawls the entire DOM and:
  # 1. Makes structural changes to prepare things for animation.
  # 2. Returns a tree of DOM references that we'll link Symbols to.
  svgData = Scene.crawl SVG.root
  
  # We're done the initial traversal of the SVG. It's now safe for systems to mutate it.
  Make "SVGReady"
  
  # We need to wait a bit for ScopeProcessors
  setTimeout ()->
  
    # By now, we're assuming all ScopeProcessors are ready.
    Registry.closeRegistration "ScopeProcessor"
    
    # Inform all systems that it's now safe to use Scope.
    Make "ScopeReady"
    
    # By now, we're assuming all Controls & Settings are ready.
    Registry.closeRegistration "Control"
    Registry.closeRegistration "SettingType"
    
    # Inform all systems that we've just finished setting up Controls.
    Make "ControlReady"
    
    # We need to wait a bit for Symbols
    setTimeout ()->
      
      # By now, we're assuming all Symbols are ready.
      Registry.closeRegistration "Symbols"
      Registry.closeRegistration "SymbolNames"
      
      # Use the DOM references collected earlier to build our Scene tree.
      Scene.build svgData
      svgData = null # Free this memory
      
      # Inform all systems that we've just finished setting up the scene.
      Make "SceneReady"
      
      # Inform all systems that bloody everything is done.
      Make "AllReady"
