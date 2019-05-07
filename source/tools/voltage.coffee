Take "Ease", (Ease)->
  Voltage = (voltage, alpha = 1)->
    switch

      # Pass-through for string values
      when typeof voltage is "string"
        return voltage

      # Schematic — black
      when voltage is Voltage.black
        return renderString 0, 0, 0, alpha

      # Schematic — white
      when voltage is Voltage.white
        return renderString 255, 255, 255, alpha

      # Legacy Electric
      when voltage is Voltage.electric
        return renderString 0, 218, 255, alpha

      # Magnetic
      when voltage is Voltage.magnetic
        return renderString 141, 2, 155, alpha

      # Zero voltage
      when voltage is Voltage.zero
        return renderString 0, 0, 0, alpha

      # Normal — green to blue
      else
        h = Ease.linear voltage, Voltage.min, Voltage.max, 100, 180
        return renderHSLString h, 100, 50, alpha


  Voltage.black = 101
  Voltage.white = -101
  Voltage.ground = 0
  Voltage.zero = 0
  Voltage.min = 1
  Voltage.med = 50
  Voltage.max = 100
  Voltage.electric = 1000
  Voltage.magnetic = 1001


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


  Make "Voltage", Voltage
