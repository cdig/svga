Take ["Action", "Stage", "DOMContentLoaded"],
(      Action ,  Stage)->
  
  activities = {} # Stores the `activity` code definition objects
  stages = {} # Stores the Stages, by id
  waiting = [] # Stores svgaElms waiting for corresponding activity definiton object

  
  initActivityElm = (svgaElmData)->
    activity = activities[svgaElmData.activityName]
    id = svgaElmData.id or svgaElmData.activityName
    stages[id] = Stage activity
    # Uh oh — This is global to all Stages!
    Action "setup"
    Action "schematicMode"
    svgaElmData # pass through
  
  
  err = (elm, msg)->
    console.log elm
    throw msg
  
  
  # This is taken in:
  # svg-activity-starter's top.coffee
  # svg-activity-starter's activity-loader.coffee
  # svg-activity-loader's svg-activity-loader.coffee
  Make "SVGActivity", SVGActivity =
    
    registerActivity: (activity)->
      activities[activity._activityName] = activity
      toRemove = for svgaElmData in waiting when svgaElmData.activityName is activity._activityName
        initActivityElm svgaElmData
      
      waiting.splice i, 1 for v, i in toRemove
    
    
    getActivity: (activityID)->
      throw "DEPRECATED: getActivity"
      # return stages[activityName]
    
    
    start: (svgActivityElm)->
      svgaElmData =
        activityName: svgActivityElm.getAttribute("name") or err svgActivityElm, ' ^ This <svg-activity> is missing a name attribute. Please add something like name="special-delivery", where "special-delivery" is the name from your svg-activity.json file.'
        id: svgActivityElm.getAttribute("id") or err svgActivityElm, " ^ This <svg-activity> is missing an id attribute. Please add something like id=\"#{svgActivityElm.getAttribute("name")}\"."
        objectElm: svgActivityElm.querySelector("object") or err svgActivityElm, ' ^ This <svg-activity> must contain an <object>.'
      
      # Already inited — Resume the activity if paused
      if stages[svgaElmData.id]?
        # TODO
      
      # Not yet inited — Init if possible
      else if activities[svgaElmData.activityName]?
        initActivityElm svgaElmData
      
      # Not possible to init yet
      else
        waiting.push svgaElmData
    
    
    stop: (svgActivityElm)->
      console.log "TODO: Implement SVGActivity.stop()"
