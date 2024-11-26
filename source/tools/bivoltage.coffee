Take "Ease", (Ease)->
  console.log "bivoltage take has run"
  Bivoltage = (bivoltage, alpha = 1)->
	console.log "bivoltage line 4 has run"
	switch

	  # Pass-through for string values
	  when typeof bivoltage is "string"
		return bivoltage

	  # Schematic — black
	  when bivoltage is Bivoltage.black
		  console.log "bivoltage black"
		return renderString 0, 0, 0, alpha

	  # Schematic — white
	  # when bivoltage is Voltage.white
	  #   return renderString 255, 255, 255, alpha

	  # Legacy Electric
	  # when bivoltage is Voltage.electric
	  #   return renderString 0, 218, 255, alpha

	  # Magnetic
	  when bivoltage is Bivoltage.magnetic
		return renderString 141, 2, 155, alpha

	  # Inert
	  when bivoltage is Bivoltage.inert
		return renderHSLString 184, 9, 50, alpha

	  # Zero bivoltage
	  when bivoltage is Bivoltage.zero
		return renderString 0, 0, 0, alpha

	  # Normal — green to blue
	  else
		console.log "bivoltage else"
		h = Ease.linear bivoltage, Bivoltage.negMax, Bivoltage.posMax, 240, 0
		return renderHSLString h, 100, 50, alpha


  Bivoltage.black = 0
  Bivoltage.inert = -101
  Bivoltage.ground = 0
  Bivoltage.zero = 0
  Bivoltage.posMin = 1
  Bivoltage.negMin = -1
  Bivoltage.posMax = 100
  Bivoltage.negMax = -100
  # Voltage.electric = 1000
  Bivoltage.magnetic = 1001


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