Take "Ease", (Ease)->
  Bivoltage = (bivoltage, alpha = 1)->
    switch
    # Pass-through for string values
      when typeof bivoltage is "string"
        return bivoltage

    # Inert
      when bivoltage is Bivoltage.inert
        return renderHSLString 184, 9, 50, alpha

    # Zero bivoltage
      when bivoltage is Bivoltage.zero
        return renderString 0, 0, 0, alpha

    # Normal — green to blue
      when bivoltage > 0 and bivoltage < 100
        l = Ease.linear bivoltage, Bivoltage.posMin, Bivoltage.posMax, 80, 50
        return renderHSLString 0, 100, l, alpha
      when bivoltage < 0 and bivoltage > -100
        l = Ease.linear bivoltage, Bivoltage.negMin, Bivoltage.negMax, 50, 80
        return renderHSLString 240, 100, l, alpha
      # else
      #   h = Ease.linear bivoltage, Bivoltage.negMin, Bivoltage.negMax, 51, 180
      #   return renderHSLString h, 100, 50, alpha


  Bivoltage.inert = -101
  Bivoltage.zero = 0
  Bivoltage.posMin = 1
  Bivoltage.negMin = -1
  Bivoltage.posMax = 100
  Bivoltage.negMax = -100


  renderString = (r, g, b, a)->
    if a >= .99
      return "rgb(#{r},#{g},#{b})"
    else
      return "rgba(#{r},#{g},#{b},#{a})"

  renderHSLString = (h, s, l, a)->
    if a >= .99
      return "hsl(#{h},#{s}%,#{l}%)"
    else
      return "hsla(#{h},#{s}%,#{l}%,#{a})"

  Make "Bivoltage", Bivoltage
