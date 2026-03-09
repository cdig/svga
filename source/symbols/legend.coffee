Take ["Reaction", "Symbol", "Mode"], (Reaction, Symbol, Mode)->
    Symbol "Legend", ["Legend"], (svgElement)->
        return scope =
            setup: ()->
                svgElement.style.display = if Mode.get("legend") then 'unset' else 'none'