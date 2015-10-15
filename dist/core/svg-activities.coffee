do ()->
  activities = []
  Make "SVGActivities", SVGActivities =
    registerActivity: (activityName, activity)->
      activities[activityName] = activity

    getActivity: (activityName)->
      return activities[activityName]
