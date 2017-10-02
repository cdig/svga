Take ["FPS", "HUD", "Mode", "Tick", "SVGReady"], (FPS, HUD, Mode, Tick)->
  return unless Mode.dev
  
  Tick ()->
    fps = FPS()
    fpsDisplay = if fps < 30 then fps.toFixed(1) else Math.ceil(fps)
    color = if fps <= 10 then "#C00" else if fps <= 20 then "#E608" else "#0003"
    HUD "FPS", fpsDisplay, color
