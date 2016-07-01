Take ["Action", "RAF", "ScopeBuilder", "SVGCrawler", "DOMContentLoaded"], (Action, RAF, ScopeBuilder, SVGCrawler)->
  
  # This is the very first code that touches the DOM. It crawls the entire DOM tree and:
  # A) Does various transformations, to bring things to a more ideal arrangement for animating.
  # B) Grabs a bunch of references (crawlerData) that we'll use to link Symbol code to the DOM.
  svg = document.rootElement
  crawlerData = SVGCrawler svg
  
  # Allow other systems that mutate the DOM to do their thing, now that we're done preprocessing
  Make "SVGReady"
  
  # Give Symbols a bit more time to be defined, since some of them might be waiting on Takes
  setTimeout ()->
    # By now, we're assuming all Symbols are ready
    
    # Use the references collected during preprocessing, and the Symbols, to build our Scope tree
    rootScope = ScopeBuilder crawlerData
    
    # This is used by Reactions
    # THis should not be used by anything that calls Make, otherwise we'll probably end up with a circular ref.
    Make "root", rootScope
    
    # Ready to rock!
    Action "setup"
    Action "Schematic:Show"
    
    Take ["TopBarReady", "ControlPanelReady"], ()->
      svg.style.opacity = 1
