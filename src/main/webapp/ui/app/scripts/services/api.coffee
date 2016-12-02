angular.module('ibnsina').service '$api', ['$rootScope', 'Restangular', ($rootScope, Restangular)->
	
	Restangular.setErrorInterceptor (response, deferred, responseHandler)->
		# console.log response
		if response.status == 200
			return false # error handled

		if response.status = 403
			if window.location.pathname.indexOf('index.html') != -1
				return window.location = domainURL+'/api/login.html'
	
		return true # error not handled

	# CRUD
	crud =
		# GET ":url/"
		list: (process)->
			Restangular.all(this.url).getList().then (data)->
				process data
				return
			return

		# GET ":url/{id}"
		get: (id, process)->
			Restangular.one(this.url, id).get().then (data)->
				process data
				return
			return

		# POST ":url/"
		create: (plain, process)->
			Restangular.all(this.url).post(plain).then (data)->
				process data
				return
			return

		# PUT ":url/{id}"
		update: (plain, process)->
			Restangular.one(this.url, plain.id).customPUT(plain).then (data)->
				process data
				return
			return

		# DELETE ":url/{id}"
		delete: (id, process)->
			Restangular.one(this.url, id).remove({}).then (data)->
				process data
				return
			return

	#core
	this.core =
		# GET "/"
		
		# GET "/authorized"
		authorized: (process)->
			Restangular.one('authorized').get().then (data)->
				process data
				return
			return

	#openapi
	this.openapi =
		url: 'openapi'
		# register
		register: (plain, process)->
			Restangular.all(this.url+'/register').post(plain).then (data)->
				process data
				return
			return

	# secure
	this.secure = 
		role: angular.copy crud
	this.secure.role.url = 'secure/roles'

	# user
	this.user = angular.copy crud
	this.user.url = 'secure/users'
	
	# GET "secure/users/current"
	this.user.current = (process)->
		Restangular.one(this.url+'/current').get().then (data)->
			process data.plain()
			return
		return
	
	# GET "secure/users/login/{login}"
	# PUT "secure/users/password/change"
	# GET "secure/users/{id}/password/reset"
	
	# GET "secure/users/{id}/roles"
	this.user.roles = (id, process)->
		Restangular.all(this.url+'/' + id + '/roles').getList().then (data)->
			process data.plain()
			return
		return
	
	# GET "secure/users/logout"
	this.user.logout = (process)->
		Restangular.one(this.url+'/logout').get().then (data)->
			process data
			return
		return

	# room
	this.room = angular.copy crud
	this.room.url = 'secure/rooms'

	this.room.users = 
		url: 'secure/rooms'
		list: (id, process)->
			Restangular.all(this.url+'/' + id + '/users').getList().then (data)->
				process data.plain()
				return
			return

		create: (id, plain, process)->
			Restangular.all(this.url+'/' + id + '/users').post(plain).then (data)->
				process data
				return
			return

		delete: (id, userId, process)->
			Restangular.one(this.url+'/' + id + '/users', userId).remove({}).then (data)->
				process data
				return
			return

		message:
			send: (plain, process)->
				Restangular.all('secure/rooms/' + plain.roomId + '/users/' + plain.userId + '/message').post(plain).then (data)->
					process data
					return
				return


	

	$rootScope.$api = this # global service

	return
]