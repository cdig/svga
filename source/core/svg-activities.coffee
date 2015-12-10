do ()->
  Take ['crank', 'defaultElement', 'button','Joystick', 'SVGActivity', 'DOMContentLoaded'], (crank, defaultElement, button, Joystick, SVGActivity)->
    activityDefinitions = []
    activities = []
    waitingActivities = []
    waitingForRunningActivity = []
    Make "SVGActivities", SVGActivities =
      registerActivityDefinition: (activity)->
        activityDefinitions[activity._name] = activity
        toRemove = []
        for waitingActivity in waitingActivities 
          if waitingActivity.name is activity._name
            setTimeout ()->
              SVGActivities.runActivity(waitingActivity.name, waitingActivity.id, waitingActivity.svg)
            toRemove.push waitingActivity
        for remove in toRemove
          waitingActivities.splice(waitingActivities.indexOf(remove), 1)


        
      getActivity: (activityID)->
        return activities[activityName]

      startActivity: (activityName, activityId, svgElement)->
        if activities[activityId]?
          return
        if not activityDefinitions[activityName]
          waitingActivities.push {name: activityName, id: activityId, svg: svgElement}
        else
          setTimeout ()->
            SVGActivities.runActivity(activityName, activityId, svgElement)

      runActivity: (activityName, id, svgElement, waitingActivity)->
        activity = activityDefinitions[activityName]
        activity.registerInstance('joystick', 'joystick')
        activityName = activity._name
        activity.crank = crank
        activity.button = button
        activity.defaultElement = defaultElement
        activity.joystick = Joystick
        svgActivity = SVGActivity()
        for pair in activity._instances
          svgActivity.registerInstance(pair.name, activity[pair.instance])
        svgActivity.registerInstance('default', activity.defaultElement)
        svg = svgElement.contentDocument.querySelector('svg')

        svgActivity.setupDocument(activityName, svg)
        svgElement.style.opacity = 1.0
        activities[id] = svgActivity
        Make id, activities[id].root

