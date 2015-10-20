# Take ["PageScrollWatcher", "PureDom"], (PageScrollWatcher, PureDom)->

#   PageScrollWatcher.onPageChange ()->
#     currentPage = PageScrollWatcher.getCurrentPage()
#     svgActivity = currentPage.querySelector("svg-activity")
#     svgActivities = currentPage.querySelectorAll("svg-activity")
#     for svgActivity in svgActivities
#       name = svgActivity.id
#       fileref = document.createElement('script')
#       srcName = "#{name}-activity.js"
#       fileref.setAttribute("src", srcName)
#       documentChildren = document.getElementsByTagName("head")[0].children
#       for child in documentChildren
#         if child.getAttribute("src")? and child.getAttribute("src") is srcName
#           return
#       parent = PureDom.querySelectorParent(svgActivity, "cd-map")
#       document.getElementsByTagName("head")[0].appendChild(fileref)     
      
#       #an SVG will affect mouse events on the window which will break the editor
#       #therefore, if the activity is within a cd-map, and that cd-map has editable items
#       #let's place a layer overtop of the svg-activity that allows for dragging and dropping
#       #with the editor.
#       editable = false
#       if parent?
#         parentChildren = parent.querySelectorAll("[editable]")
#         if parentChildren.length > 0
#           editable = true

#       if editable
#         coverDiv = document.createElement("div")
#         coverDiv.setAttribute("style", "width:100%; height:#{svgActivity.offsetHeight}px; position: absolute; top: 0; left: 0;")
#         svgActivity.appendChild(coverDiv)

  

