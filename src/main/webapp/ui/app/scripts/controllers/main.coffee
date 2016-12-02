angular.module('ibnsina').controller 'MainCtrl', ['$scope', '$rootScope', '$auth', '$state', ($scope, $rootScope, $auth, $state)->
	$rootScope.covering = true
	$rootScope.domain = domainURL

	# $auth.authenticate()
	$auth.authorized ->
		$auth.authenticate()
	, ->
		$state.transitionTo 'register'

	$scope.navs = [
		name: 'users'
		url: 'users'
		label: 'users'
		icon: 'fa-user-plus'
	,
		name: 'lines'
		url: 'line'
		label: 'lines'
		icon: 'fa-bars'
	,
		name: 'queue'
		url: 'queue'
		label: 'queue'
		icon: 'fa-exchange'
	]

	# current url
	$rootScope.currentUrl = ->
		document.URL

	return
]