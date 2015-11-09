Take "DOMContentLoaded", ()->
  svgActivities = document.querySelectorAll("svg-activity")
  for svgActivity in svgActivities
    svgActivity.querySelector("object").style.opacity = 0