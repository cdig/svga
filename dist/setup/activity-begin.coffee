activity = {}
activity._name = "%activity_name"
activity._instances = [] #make into _instance
activity.registerInstance = (instanceName, stance)->
  activity._instances.push {name: instanceName, instance: stance}
do ->
  Take "SVGActivities", (SVGActivities)->
    SVGActivities.registerActivityDefinition(activity)