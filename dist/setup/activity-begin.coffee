activity = {}
activity._instances = [] #make into _instance
activity.registerInstance = (instanceName, stance)->
  activity._instances.push {name: instanceName, instance: stance}