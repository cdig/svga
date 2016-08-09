Take "Registry", (Registry)->
  Symbol = (symbolName, instanceNames, symbol)->
    symbol.symbolName = symbolName
    Registry.set "Symbols", symbolName, symbol
    Registry.set "SymbolNames", instanceName, symbol for instanceName in instanceNames
  
  Symbol.forSymbolName = (symbolName)-> Registry.get "Symbols", symbolName
  Symbol.forInstanceName = (instanceName)-> Registry.get "SymbolNames", instanceName
  
  Make "Symbol", Symbol
