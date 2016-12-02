angular.module('ibnsina').controller 'RoomCtrl', ['$scope', '$state','$rootScope', '$api', 'MessagesMonitoring', '$security', '$mode', '$cookies', ($scope, $state, $rootScope, $api, Messages, $security, $mode, $cookies)->
	$rootScope.current = 'room'

	# $security.loadSecurity ->
	# 	if $security.hasRole 'ADMIN'
	# 		fetch()
	# 	else
	# 		$state.transitionTo 'error-access'

	# 	return

	pureModel =
		room:
			add:
				id: null
				name: null
			edit:
				id: null
				name: null
		select:
			operator: null

	$scope.model = angular.copy pureModel
	
	init = ->
		$scope.model = angular.copy pureModel
		return

	# fetch = ->
	# 	init()
	# 	$rootScope.loading = true
	# 	$api.room.list (data)->
	# 		$rootScope.loading = false
	# 		$scope.rooms = data.plain()

	# 		$mode.change 'list'
	# 		return
	# 	return

	$scope.preAdd = ->
		init()
		$mode.change('add')
		return

	getAvailableUsers = ->
		if not $scope.model.room.edit.id
			return

		$scope.users = []
		$scope.model.room.edit.available = false
		accessToChatRoomIndex = $scope.model.room.edit.users.map (e)->
			e.id
		.indexOf Number($cookies.get 'userId')

		$scope.model.room.edit.available = accessToChatRoomIndex > -1
		
		for user in $scope.allUsers
			index = $scope.model.room.edit.users.map (e)->
				e.id
			.indexOf user.id

			if index == -1
				$scope.users.push user

		if $scope.users.length > 0
			$scope.model.select.user = $scope.users[0].id

		return

	
	fetchRoomUsers = (id)->
		$rootScope.loading = true
		$api.room.users.list id, (data)->
			$rootScope.loading = false
			$scope.model.room.edit.users = data
	# 		getAvailableUsers()
			return
		return

	$scope.add = ->
		plain =
			name: $scope.model.room.add.name

		$rootScope.loading = true
		$api.room.create plain, (data)->
			$rootScope.loading = false

			# fetch()
			$mode.change 'list'
			return
		return

	$scope.edit = ->
		plain =
			id: $scope.model.room.edit.id
			name: $scope.model.room.edit.name
		
		$rootScope.loading = true
		$api.room.update plain, (data)->
			$rootScope.loading = false
			# fetch()
			# $state.transitionTo 'line'
			$mode.change 'list'
			return
		return

	$scope.select = (room)->
		$scope.model.room.edit = room
		getAvailableUsers()
		$mode.change 'view'
		# fetchRoomUsers room.id
		return

	$scope.addUser = ->
		id = $scope.model.room.edit.id
		plain =
			id: $scope.model.select.user

		$rootScope.loading = true
		$api.room.users.create id, plain, (data)->
			$rootScope.loading = false
			fetchRoomUsers id
			# $scope.model.room.edit.users.push angular.copy $scope.allUsers[index]
			return
		return

	$scope.removeUser = (userId)->
		id = $scope.model.room.edit.id

		$rootScope.loading = true
		$api.room.users.delete id, userId, (data)->
			$rootScope.loading = false
			fetchRoomUsers id

			return
		return

	$scope.removeRoom = ->
		id = $scope.model.room.edit.id

		$rootScope.loading = true
		$api.room.delete id, (data)->
			$rootScope.loading = false
			# fetch()
			$mode.change 'list'
			return
		return

	$scope.sendMessage = ->
		plain =
			content: $scope.model.msg
			roomId: $scope.model.room.edit.id
			userId: $cookies.get 'userId'

		$api.room.users.message.send plain, (data)->
			$rootScope.loading = false
			return
		return

	# fetch()

	$scope.Messages = Messages
	$scope.$watch  ->
		$scope.Messages.response['queue']
	,
		(newvalue,oldvalue)->
			if not newvalue
				return

			if newvalue.event == 'LAUNCH_INFO'
				init()
				$scope.rooms = []
			
				$scope.allUsers = newvalue.users

				rooms = angular.copy newvalue.rooms
				for roomInfo in rooms
					roomInfo.room.users = roomInfo.users
					roomInfo.room.messages = roomInfo.messages
					for msg in roomInfo.room.messages
						index = $scope.allUsers.map (e)->
							e.id
						.indexOf msg.userId

						msg.user = angular.copy $scope.allUsers[index]
					$scope.rooms.push roomInfo.room

				$mode.change 'list'
	
			else if newvalue.event == 'ADD_ROOM'
				room = angular.copy newvalue.room
				room.messages = []
				room.users = []
				$scope.rooms.push room
				# $mode.change 'list'

			else if newvalue.event == 'EDIT_ROOM'
				room = angular.copy newvalue.room
				
				index = $scope.rooms.map (e)->
					e.id
				.indexOf room.id
				
				$scope.rooms[index].name = room.name
				# $mode.change 'list'
				
			else if newvalue.event == 'REMOVE_ROOM'
				index = $scope.rooms.map (e)->
					e.id
				.indexOf newvalue.roomId

				$scope.rooms.splice index, 1
				getAvailableUsers()
				if $scope.model.room.edit.id
					if newvalue.roomId == $scope.model.room.edit.id
						$mode.change 'list'

			else if newvalue.event == 'ADD_USER'
				user = angular.copy newvalue.user
				$scope.allUsers.push user

				getAvailableUsers()

			else if newvalue.event == 'EDIT_USER'
				user = angular.copy newvalue.user
				
				index = $scope.allUsers.map (e)->
					e.id
				.indexOf user.id
				
				$scope.allUsers[index].name = user.name
				$scope.allUsers[index].online = user.online

			else if newvalue.event == 'REMOVE_USER'
				index = $scope.allUsers.map (e)->
					e.id
				.indexOf newvalue.userId

				$scope.allUsers.splice index, 1

				for room in $scope.rooms
					indexInsideRoom = room.users.map (e)->
						e.id
					.indexOf newvalue.userId

					if indexInsideRoom > -1
						room.users.splice indexInsideRoom, 1

				getAvailableUsers()

			else if newvalue.event == 'ADD_USER_TO_ROOM'
				index = $scope.allUsers.map (e)->
					e.id
				.indexOf newvalue.userId

				indexRoom = $scope.rooms.map (e)->
					e.id
				.indexOf newvalue.roomId

				$scope.rooms[indexRoom].users.push angular.copy $scope.allUsers[index]
				
				getAvailableUsers()

			else if newvalue.event == 'REMOVE_USER_FROM_ROOM'
				indexRoom = $scope.rooms.map (e)->
					e.id
				.indexOf newvalue.roomId

				indexInsideRoom = $scope.rooms[indexRoom].users.map (e)->
					e.id
				.indexOf newvalue.userId

				if indexInsideRoom > -1
					$scope.rooms[indexRoom].users.splice indexInsideRoom, 1
				
				getAvailableUsers()

			else if newvalue.event == 'MESSAGE_ROOM'
				msg = angular.copy newvalue.message
				
				indexRoom = $scope.rooms.map (e)->
					e.id
				.indexOf msg.roomId

				index = $scope.allUsers.map (e)->
					e.id
				.indexOf msg.userId

				msg.user = angular.copy $scope.allUsers[index] 	
				$scope.rooms[indexRoom].messages.push msg
				
				# getAvailableUsers()
			return
	,
		true

	return
]