angular.module('ibnsina').controller 'RegisterCtrl', ['$scope', '$rootScope', '$api', '$auth', '$mode', ($scope, $rootScope, $api, $auth, $mode)->
	$rootScope.current = 'register'
	
	$scope.model = 
		login: null
		name: null
		password: null

	$mode.change 'register'

	$scope.register = ->
		plain =
			login: $scope.model.login
			name: $scope.model.name

		$api.openapi.register plain, (data)->
			if not data.field.value
				$scope.loginNotAvailable = true
			else
				$scope.model.password = data.field.value
				$mode.change 'signin'
			return
		return
	return
]