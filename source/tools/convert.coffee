do ()->
  mappings =

    # Pressure
    psi:
      kPa: 6.894757
      bar: 0.06894757 # For bar, use metric units for all non-bar values

    # Volume
    gal:
      L: 3.7854 # US gallon
    cc:
      in3: 0.06102374

    # Distance
    in:
      mm: 25.4
      cm: 2.54
      m: 0.0254

    # Area
    in2:
      mm2: 645.16
      cm2: 6.4516

    # Weight
    lb:
      kg: 0.4535924

  Convert = {}

  for a, bs of mappings
    for b, q of bs
      do (q)->
        (Convert[a] ?= {})[b] = (v)-> v * q
        (Convert[b] ?= {})[a] = (v)-> v * 1/q

  Convert.psi.kpa = ()-> throw "You must use Convert.psi.kPa — with a capital P"
  Convert.kpa = psi: ()-> throw "You must use Convert.kPa.psi — with a capital P"
  Convert.gal.l = ()-> throw "You must use Convert.gal.L — with a capital L"
  Convert.l = gal: ()-> throw "You must use Convert.L.gal — with a capital L"
  Convert.lbs = kg: ()-> throw "You must use Convert.lb.kg — lb is singular"
  Convert.kg.lbs = ()-> throw "You must use Convert.kg.lb — lb is singular"

  Make "Convert", Convert
