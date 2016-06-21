Take ["Action", "button", "crank", "defaultElement", "Joystick", "SetupGraphic", "slider", "RootBuilder", "DOMContentLoaded"],
(      Action ,  button ,  crank ,  defaultElement ,  Joystick ,  SetupGraphic ,  slider ,  RootBuilder)->
  
  activityDefinitions = []
  waitingObjects = []
  runningActivities = []
  
  
  runActivity = (data)->
    activityDefinition = activityDefinitions[data.activityName]
    id = data.id or data.activityName
    
    activityDefinition.defaultElement = defaultElement
    activityDefinition.registerInstance "joystick", "joystick"
    activityDefinition.crank = crank
    activityDefinition.button = button
    activityDefinition.slider = slider
    activityDefinition.joystick = Joystick
    
    svg = SetupGraphic data.object.contentDocument.querySelector "svg"
    
    rootActivity = RootBuilder
    runningActivities[id] = rootActivity
    for pair in activityDefinition._waitingInstances
      rootActivity.registerInstance(pair.name, activityDefinition[pair.instance])
    rootActivity.registerInstance "default", activityDefinition.defaultElement
    rootActivity.setupSvg svg
    Make id, rootActivity.root
    
    Action "setup"
    Action "schematicMode"
    
    data # pass through
  
  
  # This is taken in:
  # svg-activity-starter's top.coffee
  # svg-activity-starter's activity-start.coffee
  # svg-activity-loader's svg-activity-loader.coffee
  Make "SVGActivity", SVGActivity =
    
    registerActivity: (activityDefinition)->
      activityDefinitions[activityDefinition._activityName] = activityDefinition
      toRemove = for o in waitingObjects when o.activityName is activityDefinition._activityName
        runActivity o
      
      waitingObjects.splice i, 1 for v, i in toRemove
    
    
    getActivity: (activityID)->
      throw "DEPRECATED: getActivity"
      # return runningActivities[activityName]
    
    
    # Elm is an <svg-activity>
    start: (elm)->
      data =
        activityName: elm.getAttribute "name"
        id: elm.getAttribute "id"
        object: elm.querySelector "object"
      
      if activityDefinitions[data.activityName]?
        runActivity data
      else
        waitingObjects.push data
    
    
    stop: (elm)->
      console.log "TODO: Implement SVGActivity.stop()"
