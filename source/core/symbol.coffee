Take [], ()->
  bySymbolName = {}
  byInstanceName = {}
  first = true
  
  Symbol = (symbolName, instanceNames, symbolFn)->
    
    # This will inform the rest of the system that we have started receiving symbols
    Make("SymbolsReady") if first
    first = false
    
    if bySymbolName[symbolName]?
      throw "The symbol \"#{symbolName}\" is defined more than once. You'll need to change one of the definitions to use a more unique name."
    
    symbol =
      create: symbolFn
      name: symbolName
    
    bySymbolName[symbolName] = symbol
    
    for instanceName in instanceNames
      if byInstanceName[instanceName]?
        throw "The instance \"#{instanceName}\" is defined more than once, by Symbol \"#{byInstanceName[instanceName].symbolName}\" and Symbol \"#{symbolName}\". You'll need to change one of these instances to use a more unique name. You might need to change your FLA. This is a shortcoming of SVGA — sorry!"
      byInstanceName[instanceName] = symbol
  
  Symbol.forSymbolName = (symbolName)-> bySymbolName[symbolName]
  Symbol.forInstanceName = (instanceName)-> byInstanceName[instanceName]
  
  Make "Symbol", Symbol
