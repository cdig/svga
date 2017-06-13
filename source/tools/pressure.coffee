do ()->
  Pressure = (pressure, alpha = 1)->
    switch
      
      # Pass-through for string values
      when typeof pressure is "string"
        return pressure
      
      # Schematic — black
      when pressure is Pressure.black
        return renderString 0, 0, 0, alpha
      
      # Schematic — white
      when pressure is Pressure.white
        return renderString 255, 255, 255, alpha

      # Vacuum pressure - purple
      when pressure is Pressure.vacuum
        return renderString 255, 0, 255, alpha
      
      # Zero pressure - light blue - also non-charged drain lines
      when pressure is Pressure.atmospheric
        return renderString 0, 153, 255, alpha
      
      # Zero pressure - blue - also charged drain lines
      when pressure is Pressure.drain
        return renderString 0, 0, 255, alpha
      
      # Electric
      when pressure is Pressure.electric
        return renderString 0, 218, 255, alpha
      
      # Magnetic
      when pressure is Pressure.magnetic
        return renderString 141, 2, 155, alpha
      
      # Normal - yellow to orange (102 green)
      when pressure < Pressure.med
        green = Pressure.med - pressure
        green *= 153/(Pressure.med-1)
        green += 102
        return renderString 255, green|0, 0, alpha
    
      # Normal - orange (102 green) to red
      when pressure >= Pressure.med
        green = Pressure.max - pressure
        green *= 102/Pressure.med
        return renderString 255, green|0, 0, alpha
  
  
  Pressure.black = 101
  Pressure.white = -101
  Pressure.vacuum = -2
  Pressure.atmospheric = -1
  Pressure.drain = 0
  Pressure.zero = 0
  Pressure.min = 1
  Pressure.med = 50
  Pressure.max = 100
  Pressure.electric = 1000
  Pressure.magnetic = 1001
  
  
  renderString = (r, g, b, a)->
    if a >= .99
      return "rgb(#{r},#{g},#{b})"
    else
      return "rgba(#{r},#{g},#{b},#{a})"
  
  
  Make "Pressure", Pressure
