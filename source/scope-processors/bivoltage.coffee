# Depends on style
Take ["Bivoltage", "Registry", "ScopeCheck", "SVG"], (Bivoltage, Registry, ScopeCheck, SVG)->
	Registry.add "ScopeProcessor", (scope)->
		ScopeCheck scope, "bivoltage"

		bivoltage = null

		accessors =
			get: ()-> bivoltage
			set: (val)->
				if bivoltage isnt val
					bivoltage = val
					if scope._setColor?
						scope._setColor bivoltage
					else
						scope.fill = Bivoltage scope.bivoltage

		Object.defineProperty scope, "bivoltage", accessors