angular.module('ibnsina').service '$security', ['$rootScope', '$state', '$cookies', 'Restangular', '$api', ($rootScope, $state, $cookies, Restangular, $api)->
	# page access security: permission, role
	roles = []
	
	hasRoleFn = (roleName)->
		hasRole = false
		if roles and roles.length > 0
			for role in roles
				if role.name == roleName
					hasRole = true
					break
		hasRole

	this.hasRole = hasRoleFn
	
	this.loadSecurity = (fn)->
		userId = $cookies.get 'userId'
		$api.user.roles userId, (data)->
			roles = data
			
			if fn
				fn();
			else
				isAdmin = hasRoleFn 'ADMIN'
				isGuest = hasRoleFn 'GUEST'
				if isGuest
					$state.transitionTo 'room'
				else if isAdmin
					$state.transitionTo 'room'

			return

		return

	$rootScope.$security = this # global service
	return
]