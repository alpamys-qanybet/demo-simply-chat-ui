angular.module('ibnsina').directive "accessStatus", [ ->
	restrict: "A"
	templateUrl: 'scripts/directives/access-status/access-status.html'
	scope:
		map: '='
		prefix: '='
		user: '='
		room: '='
		add: '&'
		remove: '&'

	controller: ["$scope", "$element", (scope, elm)->
	]
	
	link: (scope, elm, attrs)->
		scope.addFn = ->
			scope.add({user:scope.user, room:scope.room})
			return
		
		scope.removeFn = ->
			scope.remove({user:scope.user, room:scope.room})
			return

		return
]