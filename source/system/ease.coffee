# Ease
# Unlike other easing functions you'll find through Google, these easing functions are ALMOST human-
# readable (typographic pun intended). Also, they get called with lots of arguments, rather than the
# usual four. The reason being.. the four-argument version of these functions assumes your input
# value never goes below zero, and that you want to pass in deltas (like the duration) rather than
# specify explicit min and max values (like start-time and end-time). But if you are smart, and go
# with min/max ranges, then you get to use the easing functions for all sorts of stuff than purely
# "easing", which is awesome. These functions also take an optional final argument that clips the
# input between 0 and 1, which is often very helpful.


do ()->
  Make "Ease", Ease =
    
    sin: (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
      return outputMin if inputMin is inputMax # Avoids a divide by zero
      input = Math.max inputMin, Math.min inputMax, input if clip
      p = (input - inputMin) / (inputMax - inputMin)
      cos = Math.cos(p * Math.PI)
      return (.5 - cos/2) * outputMax + outputMin
    
    
    cubic: (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
      Ease.power(input, 3, inputMin, inputMax, outputMin, outputMax, clip)
    
    
    linear: (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
      return outputMin if inputMin is inputMax # Avoids a divide by zero
      input = Math.max inputMin, Math.min inputMax, input if clip
      input -= inputMin
      input /= inputMax - inputMin
      input *= outputMax - outputMin
      input += outputMin
      return input
    
    
    power: (input, power = 1, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
      return outputMin if inputMin is inputMax # Avoids a divide by zero
      input = Math.max inputMin, Math.min inputMax, input if clip
      outputDiff = outputMax - outputMin
      inputDiff = inputMax - inputMin
      p = (input-inputMin) / (inputDiff/2)
      if p < 1
        return outputMin + outputDiff/2 * Math.pow(p, power)
      else
        return outputMin + outputDiff/2 * (2 - Math.abs(Math.pow(p-2, power)))
    
    
    quadratic: (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
      Ease.power(input, 2, inputMin, inputMax, outputMin, outputMax, clip)
    
    
    quartic: (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true)->
      Ease.power(input, 4, inputMin, inputMax, outputMin, outputMax, clip)
