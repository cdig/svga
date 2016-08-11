Take ["Registry", "SVGPreprocessor", "DOMContentLoaded"], (Registry, SVGPreprocessor)->
  
  # This is the very first code that touches the DOM. It crawls the entire DOM and:
  # 1. Applies transformations to bring things to a more ideal arrangement for animating.
  # 2. Returns a tree of DOM references that we'll link Symbols to.
  svgData = SVGPreprocessor.crawl document.getElementById "root"
  
  # We're done preprocessing the SVG. Tell other systems that mutate the DOM to do their thing.
  Make "SVGReady"
  
  # Give Symbols & Controls a bit more time to be defined, since some of them might be waiting on Takes.
  setTimeout ()->
    
    # By now, we're assuming all Symbols & Controls are ready.
    Registry.closeRegistration()
    
    # Use the references collected during preprocessing to build our Scope tree.
    SVGPreprocessor.build svgData
    svgData = null # free this memory
    
    # Inform the system that all our scopes are built and setup.
    Make "ScopeReady"
    
    # Inform the system that setup is complete.
    Make "AllReady"
