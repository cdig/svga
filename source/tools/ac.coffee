Take ["Ease", "Voltage"], (Ease, Voltage)->

  ANCHORS = [
    { phase: 0,   r: 255, g: 33,  b: 37  }
    { phase: 120, r: 34,   g: 201, b: 79   }
    { phase: 240, r: 27,  g: 33,  b: 255 }
  ]

  smoothstep = (t) -> t * t * (3 - 2 * t)

  lerpColor = (a, b, t) ->
    r: a.r + (b.r - a.r) * t
    g: a.g + (b.g - a.g) * t
    b: a.b + (b.b - a.b) * t

  getVibrant = (phase) ->
    phase = ((phase % 360) + 360) % 360
    n = ANCHORS.length
    for i in [0...n]
      a = ANCHORS[i]
      b = ANCHORS[(i + 1) % n]
      bPhase = if b.phase is 0 then 360 else b.phase
      if phase >= a.phase and phase < bPhase
        t = smoothstep (phase - a.phase) / (bPhase - a.phase)
        return lerpColor a, b, t
    ANCHORS[0]

  getColor = (phase, saturation) ->
    toHex = (v) -> Math.max(0, Math.min(255, v)).toString(16).padStart 2, '0'
    switch
      when saturation.type == "saturation"
        vibrant = getVibrant phase
        lum = 0.299 * vibrant.r + 0.587 * vibrant.g + 0.114 * vibrant.b
        tint = 0.18
        desat =
          r: lum * (1 - tint) + vibrant.r * tint
          g: lum * (1 - tint) + vibrant.g * tint
          b: lum * (1 - tint) + vibrant.b * tint
        r = Math.round desat.r + (vibrant.r - desat.r) * saturation.value
        g = Math.round desat.g + (vibrant.g - desat.g) * saturation.value
        b = Math.round desat.b + (vibrant.b - desat.b) * saturation.value
      
      when saturation.type == "black" or saturation.type == "zero"
        r = 0
        g = 0
        b = 0

      when saturation.type == "white"
        r = 0xFF
        g = 0xFF
        b = 0xFF

      when saturation.type == "inert"
        r = 116
        g = 137
        b = 139

      when saturation.type == "magnetic"
        r = 141
        g = 2
        b = 155

    "##{toHex r}#{toHex g}#{toHex b}"

  voltageToSaturation = (voltage) ->
    saturation = {
      type: "inert",
      value: 1
    }
    
    switch

      # Pass-through for string values
      when typeof voltage is "string"
        console.log "Cannot assign string to ac.voltage"
        saturation.value = 1
        saturation.type = "inert"

      # Schematic — black
      when voltage is Voltage.black
        saturation.value = 1
        saturation.type = "black"

      # Schematic — white
      when voltage is Voltage.white
        saturation.value = 1
        saturation.type = "white"

      # Legacy Electric
      when voltage is Voltage.electric
        console.log "Voltage.electric not supported for AC lines"
        saturation.value = 1
        saturation.type = "inert"

      # Magnetic
      when voltage is Voltage.magnetic
        saturation.value = 1
        saturation.type = "magnetic"
        # return renderString 141, 2, 155, alpha

      # Inert
      when voltage is Voltage.inert
        saturation.value = 1
        saturation.type = "inert"
        # return renderHSLString 184, 9, 50, alpha

      # Zero voltage
      when voltage is Voltage.zero
        saturation.value = 1
        saturation.type = "zero"

      # Normal — green to blue
      else
        t = (Math.max(1, Math.min(100, voltage))-1)/99
        saturation.value = 0.2 + t * 0.8
        saturation.type = "saturation"

    return saturation

  AC = (phase, voltage = 0) ->
    saturation = voltageToSaturation voltage
    getColor phase, saturation

  Make "AC", AC