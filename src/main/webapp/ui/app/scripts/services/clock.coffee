angular.module('ibnsina').service '$clock', ['$rootScope', '$scope', '$interval', ($rootScope, $scope, $interval)->
	$rootScope.res = new Date()
	
	this.init = ->
		$interval ->
			$rootScope.res = new Date()
			return
		,
			1000

		return

	$rootScope.$clock = this

	return
]