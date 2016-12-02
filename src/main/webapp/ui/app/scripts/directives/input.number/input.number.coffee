angular.module('ibnsina').directive "inputNumber", ["$cookies", ($cookies)->
	restrict: "EA"
	transclude: true
	templateUrl: 'scripts/directives/input.number/input.number.html'
	scope:
		'name': '@'
		'validator': '='
		'model': '='
		'label': '@'
		'min': '='
		'max': '='
	
	controller: ($scope, $element)->
		
	link: (scope, elm, attrs)->

]