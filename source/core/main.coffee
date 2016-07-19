Take ["ScopeBuilder", "SVGCrawler", "DOMContentLoaded"], (ScopeBuilder, SVGCrawler)->
  
  # This is the very first code that touches the DOM. It crawls the entire DOM tree and:
  # 1. Applies transformations to bring things to a more ideal arrangement for animating.
  # 2. Returns a tree of DOM references that we'll link Symbols to.
  crawlerData = SVGCrawler document.getElementById "root"
  
  # We're done preprocessing the SVG. Tell other systems that mutate the DOM to do their thing.
  Make "SVGReady"
  
  # Give Symbols & Controls a bit more time to be defined, since some of them might be waiting on Takes.
  setTimeout ()->
    # By now, we're assuming all Symbols & Controls are ready.
    
    # Use the references collected during preprocessing to build our Scope tree.
    ScopeBuilder crawlerData
    
    # Run all the scope setup functions.
    Make "ScopeSetup"
    
    # Inform the system that all our scopes are built and setup.
    Make "ScopeReady"
    
