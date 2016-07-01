# Dispatch can be called with either a function, or a function name, as the second arg.
# If it's a function, then we'll call that function once with every node in the tree.
# If it's a name, then we'll lookup that name on each node and call it (no args).
# The "name" variation is much more common. The first time you call it, we cache
# all the functions we find in the tree. Subsequent calls will just loop the cache.

do ()->
  cache = {}
  
  Make "Dispatch", (node, action, sub = "children")->
    if typeof action is "function"
      dispatchWithFn node, action, sub
    else
      cache[sub] ?= {}
      unless cache[sub][action]?
        subcache = cache[sub][action] ?= []
        buildSubCache node, action, sub, subcache
      fn() for fn in cache[sub][action]
  
  buildSubCache = (node, name, sub, subcache)->
    subcache.push node[name] if typeof node[name] is "function"
    buildSubCache child, name, sub, subcache for child in node[sub]
  
  dispatchWithFn = (node, fn, sub)->
    fn node
    dispatchWithFn child, fn, sub for child in node[sub]
