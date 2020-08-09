Take [], ()->

  Make "Vec", Vec =
    angle: (a, b)->
      Math.atan2 b.y - a.y, b.x - a.x

    distance: (a, b)->
      dx = b.x - a.x
      dy = b.y - a.y
      Math.sqrt dx*dx + dy*dy
