# This is a very minimal wrapper around localStorage.
# You are expected to do your own type conversions when getting values back.

Make "Storage", Storage = (k, v)->
  if v?
    window.top.localStorage["SVGA-" + k] = v.toString()
  else
    window.top.localStorage["SVGA-" + k]
