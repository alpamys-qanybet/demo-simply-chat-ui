angular.module('ibnsina').service '$mode', ['$rootScope', ($rootScope)->
	# toggle view mode
	current = null

	this.current = ->
		current
	
	this.change = (mode)->
		current = mode
		return
	
	$rootScope.$mode = this

	return
]