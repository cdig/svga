@activity = {}

@activity._waitingInstances = []
@activity.registerInstance = (graphicName, symbolName)->
  for waitingInstance in @activity._waitingInstances when waitingInstance.graphicName is graphicName
    console.log "registerInstance(#{graphicName}, #{symbolName}) Warning: #{graphicName} was already registered. Try picking a more unique instance name in your FLA. Please tell Ivan that you saw this error."
    return
  @activity._waitingInstances.push {graphicName: graphicName, symbolName: symbolName}

Take "SVGActivity", (SVGActivity)->
  SVGActivity.registerActivity @activity
