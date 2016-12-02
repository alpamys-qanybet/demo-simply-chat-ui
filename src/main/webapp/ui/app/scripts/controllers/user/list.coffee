angular.module('ibnsina').controller 'UsersCtrl', ['$scope', '$state','$rootScope', '$api', 'Restangular', 'notify', '$security', '$mode', ($scope, $state, $rootScope, $api, Restangular, notify, $security, $mode)->
	console.log 'UsersCtrl'
	$rootScope.current = 'users'

	$security.loadSecurity ->
		isAdmin = $security.hasRole 'ADMIN'
		if not isAdmin
			$state.transitionTo 'error-access'
	
	$scope.map = []
	$scope.map['roles'] = []

	$scope.model =
		user:
			login: null
			name: null

	$scope.$watch  ->
		$scope.model.user.login
	,
		(newvalue,oldvalue)->
			$scope.loginInvalid = false
			patt = new RegExp("^[a-z]+(\.[a-z]+)?$")
			
			if not patt.test newvalue
				$scope.loginInvalid = true
			return
	
	fetch = ->
		$api.user.list (data)->
			$scope.users = data.plain()

			$scope.users.sort (a, b)->
				a.name.localeCompare(b.name)
	
			if $scope.users.length > 0
				fetchUserRoles(0)

			$mode.change 'list'
			fetchRoles()
			return
		return

	fetchUserRoles = (index)->
		userId = $scope.users[index].id
		$api.user.roles userId, (dataRoles)->
			$scope.map['roles']['u'+userId] = dataRoles

			if index < ($scope.users.length-1) 
				fetchUserRoles(index+1)
			return
		return
	fetch()

	$scope.add = (user)->
		$api.user.create user, (data)->
			notify {
				message: 'Пользователь ' + user.name + ' успешно добавлен'
				classes: 'alert-success'
			}

			$scope.users = data

			fetch()

			return
		, (err)->
			notify {
				message: 'Пользователь ' + user.name + ' не был добавлен'
				classes: 'alert-warning'
			}
			return
		return
	
	$scope.roles = []

	fetchRoles = ->
		$api.secure.role.list (data)->
			console.log data.plain()
			$scope.roles = []
			for d in data.plain()
				$scope.roles.push d.field.value

			console.log $scope.roles
			$scope.roles
			return

		return

	return
]