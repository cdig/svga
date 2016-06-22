# This is injected above all other activity-related code that runs inside the <svg-activity>.

# The activity object is used in all symbol definitions.
# We may someday want to make it a proxy, perhaps?
activity = {}

# We gulp-replace this special string with the name from svg-activity.json.
# This helps us pair-up this code, and the <object> tag that uses it.
activity._activityName = "%activity_name"

# Because of technical debt (ugh), we need to provide a temporary version
# of registerInstance that can be used until the rest of the framework has
# loaded (because, in the current (bad) design, we don't do a good job of
# controlling load order). Once it's loaded, we properly set up all the _waitingInstances.
activity._waitingInstances = []
activity.registerInstance = (graphicName, symbolName)->
  for waitingInstance in activity._waitingInstances when waitingInstance.graphicName is graphicName
    console.log "registerInstance(#{graphicName}, #{symbolName}) Warning: #{graphicName} was already registered. Try picking a more unique instance name in your FLA. Please tell Ivan that you saw this error."
    return
  activity._waitingInstances.push {graphicName: graphicName, symbolName: symbolName}

# Finally, once SVGActivity is ready, we can give it this activity object
# so that it can do all the real setup work.
Take "SVGActivity", (SVGActivity)->
  SVGActivity.registerActivity activity
