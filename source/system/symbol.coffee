do ()->
  bySymbolName = {}
  byInstanceName = {}
  tooLate = false
  
  Symbol = (symbolName, instanceNames, symbolFn)->
    if bySymbolName[symbolName]?
      throw "The symbol \"#{symbolName}\" is defined more than once. You'll need to change one of the definitions to use a more unique name."
    
    if tooLate
      throw "The symbol \"#{symbolName}\" arrived after setup started. Please figure out a way to make it initialize faster."
    
    symbol =
      create: symbolFn
      name: symbolName
    
    bySymbolName[symbolName] = symbol
    
    for instanceName in instanceNames
      if byInstanceName[instanceName]?
        throw "The instance \"#{instanceName}\" is defined more than once, by Symbol \"#{byInstanceName[instanceName].symbolName}\" and Symbol \"#{symbolName}\". You'll need to change one of these instances to use a more unique name. You might need to change your FLA. This is a shortcoming of SVGA — sorry!"
      byInstanceName[instanceName] = symbol
  
  Symbol.forSymbolName = (symbolName)->
    tooLate = true
    bySymbolName[symbolName]
  
  Symbol.forInstanceName = (instanceName)->
    tooLate = true
    byInstanceName[instanceName]
  
  Make "Symbol", Symbol
