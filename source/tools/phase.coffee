Take "Ease", (Ease)->

  ANCHORS = [
    { phase: 0,   r: 236, g: 33,  b: 37  }
    { phase: 120, r: 0, g: 155, b: 0   }
    { phase: 240, r: 57,  g: 84,  b: 163 }
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

  getColor = (phase, saturation = 1) ->
    vibrant = getVibrant phase

    # Desaturated base: luminance-weighted gray with a hint of the hue
    lum = 0.299 * vibrant.r + 0.587 * vibrant.g + 0.114 * vibrant.b
    tint = 0.18
    desat =
      r: lum * (1 - tint) + vibrant.r * tint
      g: lum * (1 - tint) + vibrant.g * tint
      b: lum * (1 - tint) + vibrant.b * tint

    # Blend between desaturated base and full vibrant color
    r = Math.round desat.r + (vibrant.r - desat.r) * saturation
    g = Math.round desat.g + (vibrant.g - desat.g) * saturation
    b = Math.round desat.b + (vibrant.b - desat.b) * saturation

    toHex = (v) -> Math.max(0, Math.min(255, v)).toString(16).padStart 2, '0'
    "##{toHex r}#{toHex g}#{toHex b}"

  Phase = (phase, alpha = 1)->
    return getColor(phase, 1)
    # phase: 0 to 360  

  Make "Phase", Phase
