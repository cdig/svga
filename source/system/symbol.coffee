Take "Registry", (Registry)->
  Symbol = (symbolName, instanceNames, symbolFn)->
    symbol =
      create: symbolFn
      name: symbolName
    
    Registry.add "Symbol:BySymbolName", symbol, symbolName
    Registry.add "Symbol:ByInstanceName", symbol, instanceName for instanceName in instanceNames
    
  Symbol.forSymbolName = (symbolName)-> Registry.all("Symbol:BySymbolName")?[symbolName]
  Symbol.forInstanceName = (instanceName)-> Registry.all("Symbol:ByInstanceName")?[instanceName]
  
  Make "Symbol", Symbol
