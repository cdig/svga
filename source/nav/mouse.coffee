Take ["Input", "Mode", "Nav"], (Input, Mode, Nav)->
  return unless Mode.nav

  dragging = false

  liveDataGUI = null
  Take ["LiveDataGUI"], (_liveDataGUI) ->
    liveDataGUI = _liveDataGUI

  down = (e)->

    # Safely pass control of mousedown events to the live data root if the target was within live data root
    if liveDataGUI?.root?.contains?(e.target)
      return

    return if Nav.disabled
    return if e.target.hasAttribute 'block-nav'

    e.preventDefault() # Without this, shift-drag pans the ENTIRE SVG! What the hell?
    if Nav.eventInside e
      dragging = true

  drag = (e, state)->
    if dragging and state.down
      Nav.by
        x: state.deltaX
        y: state.deltaY

  up = ()->
    dragging = false


  calls =
    down: down
    downOther: down
    drag: drag
    dragOther: drag
    up: up
    upOther: up

  Input document, calls, true, false

  unless Mode.noNavDbl
    blockDbl = (elm)->
      while elm? and elm isnt document
        return elm if elm.hasAttribute "block-dbl"
        elm = elm.parentNode
      return null

    document.addEventListener "dblclick", (e)->
      return unless e.button is 0
      return if Nav.disabled
      return if e.target.hasAttribute 'block-nav'
      return if blockDbl e.target
      if Nav.eventInside e
        e.preventDefault()
        Nav.to x:0, y:0, z:0

  wheel = (e)->
    return if Nav.disabled
    return if e.target.hasAttribute 'block-nav'
    return unless e.button is 0
    if Nav.eventInside e
      e.preventDefault()

      if e.deltaMode is WheelEvent.DOM_DELTA_PIXEL
        Nav.by z: -e.deltaY / 500
      else
        Nav.by z: -e.deltaY / 20

      # Old code which was nice but sucked with mice
      # # Is this a pixel-precise input device (eg: magic trackpad)?
      # if e.deltaMode is WheelEvent.DOM_DELTA_PIXEL
      #   if e.ctrlKey # Chrome, pinch to zoom
      #     Nav.by z: -e.deltaY / 100
      #   else if e.metaKey # Other browsers, meta+scroll to zoom
      #     Nav.by z: -e.deltaY / 200
      #   else
      #     Nav.by
      #       x: -e.deltaX
      #       y: -e.deltaY
      #       z: -e.deltaZ
      #
      # # This is probably a scroll wheel # DOESN'T WORK! :(
      # else
      #   Nav.by z: -e.deltaY / 500


  document.addEventListener "wheel", wheel, passive: false
