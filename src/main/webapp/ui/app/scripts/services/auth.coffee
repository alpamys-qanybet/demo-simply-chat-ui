angular.module('ibnsina').service '$auth', ['$rootScope', '$cookies', '$api', '$security', ($rootScope, $cookies, $api, $security)->
	# security: auth
	
	this.authorized = (fnAuthorized, fnNot)->
		$api.core.authorized (data)->
			if data == 'true'
				fnAuthorized()
			else
				fnNot()
				$rootScope.covering = false	
		return
	
	fetchCurrent = ->
		$api.user.current (data)->
			$cookies.put 'userId',data.id
			$cookies.put 'login',data.login

			$security.loadSecurity()
			
			return
		return
	
	this.authenticate = ->
		$api.core.authorized (data)->
			if data == 'true'
				$cookies.put 'auth',true
				fetchCurrent()

				$rootScope.covering = false
			else
				$cookies.put 'auth',false
				window.location = domainURL+'/api/login.html'

			return
		return
	
	this.logout = ->
		$api.user.logout (data)->
			if data.field.value # true|false
				$cookies.put 'auth',false
				location.reload()
			return
		return
	
	$rootScope.$auth = this # global service

	return
]