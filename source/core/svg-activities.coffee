Take ["Action", "button", "crank", "defaultElement", "Joystick", "SetupGraphic", "slider", "SVGActivity", "DOMContentLoaded"],
(      Action ,  button ,  crank ,  defaultElement ,  Joystick ,  SetupGraphic ,  slider ,  SVGActivity)->
  
  activityDefinitions = []
  activities = []
  waitingActivities = []
  waitingForRunningActivity = []
  
  
  runActivity = (data)->
    setTimeout ()->
      activityDefinition = activityDefinitions[data.name]
      activityDefinition.registerInstance("joystick", "joystick")
      activityDefinition.crank = crank
      activityDefinition.button = button
      activityDefinition.slider = slider
      activityDefinition.defaultElement = defaultElement
      activityDefinition.joystick = Joystick
      svg = SetupGraphic data.svg.contentDocument.querySelector "svg"
      svgActivity = SVGActivity()
      activities[data.id] = svgActivity
      for pair in activityDefinition._instances
        svgActivity.registerInstance(pair.name, activityDefinition[pair.instance])
      svgActivity.registerInstance("default", activityDefinition.defaultElement)
      svgActivity.setupSvg svg
      Make data.id, svgActivity.root
      Action "setup"
      Action "schematicMode"
      data.svg.style.transition = "opacity .7s"
      data.svg.style.opacity = 1

  
  Make "SVGActivities", SVGActivities =
    
    registerActivityDefinition: (activityDefinition)->
      activityDefinitions[activityDefinition._name] = activityDefinition
      toRemove = []
      for waitingActivity in waitingActivities
        if waitingActivity.name is activityDefinition._name
          runActivity waitingActivity
          toRemove.push waitingActivity
      for remove in toRemove
        waitingActivities.splice(waitingActivities.indexOf(remove), 1)


    getActivity: (activityID)->
      console.log "DEPRECATED: getActivity"
      return activities[activityName]


    startActivity: (activityName, activityId, svgElement)->
      return if activities[activityId]?
      data =
        name: activityName
        id: activityId
        svg: svgElement
      
      if not activityDefinitions[activityName]
        waitingActivities.push data
      else
        runActivity data
