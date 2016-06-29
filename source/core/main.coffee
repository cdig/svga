Take ["Action", "DOMContentLoaded"], (Action)->
  
  # This is the very first code that touches the DOM. It crawls the entire DOM tree and:
  # A) Does various transformations, to bring things to a more ideal arrangement for animating.
  # B) Grabs a bunch of references (crawlerData) that we'll use to link Symbol code to the DOM.
  svg = document.rootElement
  crawlerData = SVGCrawler.preprocessSVG svg
  
  # Allow other systems that mutate the DOM to do their thing, now that we're done preprocessing
  Make "SVGReady"
  
  # Give Symbols a bit more time to be defined, since some of them might be waiting on Takes
  setTimeout ()->
    
    # By now, we're assuming all Symbols are ready
    
    # Now use references collected during preprocessing, and the Symbols, to build our Scope tree
    rootScope = SVGCrawler.buildScopes crawlerData
    
    # This is useful for other systems that aren't part of the scope tree but that need access to it
    # THIS INTRODUCES LOAD ORDER CHAOS IF A SYMBOL DEPENDS ON SOMETHING THAT DEPENDS ON "root"
    # PLEASE REMOVE THIS
    Make "root", rootScope
    
    # Ready to rock!
    Action "setup"
    setTimeout ()-> # Wait for setup to finish # WE PROBABLY DON'T NEED THIS
      Action "Schematic:Show"
      setTimeout ()-> # Wait for Schematic:Show to finish # WE MIGHT NOT NEED THIS
        svg.style.opacity = 1
