Take ["Action", "RAF", "ScopeBuilder", "SVGCrawler", "DOMContentLoaded"], (Action, RAF, ScopeBuilder, SVGCrawler)->
  
  # This is the very first code that touches the DOM. It crawls the entire DOM tree and:
  # A) Might do transformations, to bring things to a more ideal arrangement for animating.
  # B) Grabs a bunch of references (crawlerData) that we'll use to link Symbol code to the DOM.
  svg = document.rootElement
  crawlerData = SVGCrawler svg.querySelector "#root"
  
  # Allow other systems that mutate the DOM to do their thing, now that we're done preprocessing
  Make "SVGReady"
  
  # Give Symbols & Controls a bit more time to be defined, since some of them might be waiting on Takes
  setTimeout ()->
    # By now, we're assuming all Symbols & Controls are ready
    
    # Use the references collected during preprocessing to build our Scope tree.
    rootScope = ScopeBuilder crawlerData
    
    # This is used by Dispatch and Nav — we should figure out how to get away from this.
    Make "rootScope", rootScope
    
    # Ready to rock!
    Make "setup"
    Make "ScopeReady"
    
    Take ["TopBarReady", "NavReady"], ()->
      Make "GUIReady"
      svg.style.opacity = 1
