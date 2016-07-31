Take "Registry", (Registry)->
  Symbol = (symbolName, instanceNames, symbol)->
    Registry.set "Symbol:BySymbolName", symbolName, symbol
    Registry.set "Symbol:ByInstanceName", instanceName, symbol for instanceName in instanceNames
  
  Symbol.forSymbolName = (symbolName)-> Registry.get "Symbol:BySymbolName", symbolName
  Symbol.forInstanceName = (instanceName)-> Registry.get "Symbol:ByInstanceName", instanceName
  
  Make "Symbol", Symbol
