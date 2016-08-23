Take ["Config", "Dev", "ParentObject"], (Config, Dev, ParentObject)->
  
  Make "Mode", Mode =
    dev: Dev
    nav: Config.nav
    embed: window isnt window.top
