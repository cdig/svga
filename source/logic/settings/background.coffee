Take ["Action", "Dispatch", "Reaction", "DOMContentLoaded"],
(      Action ,  Dispatch ,  Reaction)->
  
  Make "Background", Background = (color)->
    document.rootElement.style.backgroundColor = color
  
  Background "hsl(220, 4%, 75%)"
