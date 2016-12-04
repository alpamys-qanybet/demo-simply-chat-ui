angular.module('ibnsina').directive "onlineStatus", [ ->
	restrict: "A"
	transclude: true
	templateUrl: 'scripts/directives/online-status/online-status.html'
	scope:
		map: '='
		prefix: '='
		user: '='
]