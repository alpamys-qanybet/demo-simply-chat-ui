angular.module('ibnsina').directive "selectRadio", ["$cookies", ($cookies)->
	restrict: "EA"
	templateUrl: 'scripts/directives/select.radio/select.radio.html'
	scope:
		'model': '='
		'list': '='
	
	controller: ($scope, $element)->
		
	link: (scope, elm, attrs)->
		scope.select = (item)->
			scope.model = item.value
			return
		return

]