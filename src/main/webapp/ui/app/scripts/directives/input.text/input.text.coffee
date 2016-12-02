angular.module('ibnsina').directive "inputText", ["$cookies", ($cookies)->
	restrict: "EA"
	templateUrl: 'scripts/directives/input.text/input.text.html'
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