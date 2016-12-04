angular.module('ibnsina').controller 'RoomCtrl', ['$scope', '$state','$rootScope', '$api', 'MessagesMonitoring', '$security', '$mode', '$cookies', ($scope, $state, $rootScope, $api, Messages, $security, $mode, $cookies)->
	$rootScope.current = 'room'

	$scope.thisUserId = Number($cookies.get 'userId');

	# $security.loadSecurity ->
	# 	if $security.hasRole 'ADMIN'
	# 		fetch()
	# 	else
	# 		$state.transitionTo 'error-access'

	# 	return
	$scope.allUsers = []

	$scope.prefix =
		user: 'u'
		access: 'ra'
	$scope.map = # TODO: refactor short access what is available
		user: []
		access: []

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
		
		for user in $scope.allUsers
			index = $scope.model.room.edit.users.map (e)->
				e.id
			.indexOf user.id

			indexInUsers = $scope.users.map (e)->
				e.id
			.indexOf user.id

			if index == -1 and indexInUsers == -1
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
			$mode.change 'list'
			return
		return

	$scope.select = (room)->
		$scope.model.room.edit = room
		getAvailableUsers()
		$mode.change 'view'
		return

	$scope.addUser = (userId, roomId)->
		id = roomId
		# id = null
		# if roomId
		# 	id = roomId
		# else
		# 	id = $scope.model.room.edit.id
		
		plain =
			id: userId

		$rootScope.loading = true
		$api.room.users.create id, plain, (data)->
			$rootScope.loading = false
			fetchRoomUsers id
			return
		return

	$scope.removeUser = (userId, roomId)->
		id = roomId
		# id = null
		# if roomId
		# 	id = roomId
		# else
		# 	id = $scope.model.room.edit.id

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
			$scope.model.msg = null
			$rootScope.loading = false
			return
		return

	$scope.Messages = Messages
	$scope.$watch  ->
		$scope.Messages.response['queue']
	,
		(newvalue,oldvalue)->
			if newvalue.event == 'LAUNCH_INFO'
				init()
				$scope.rooms = []
			
				$scope.allUsers = newvalue.users

				for u in $scope.allUsers
					$scope.map.user[$scope.prefix.user+u.id] = angular.copy u
					$scope.map.user[$scope.prefix.user+u.id].online = false

				rooms = angular.copy newvalue.rooms
				for roomInfo in rooms
					roomInfo.room.users = roomInfo.users
					accessToChatRoomIndex = roomInfo.room.users.map (e)->
						e.id
					.indexOf $scope.thisUserId

					$scope.map.access[$scope.prefix.access+roomInfo.room.id] = accessToChatRoomIndex > -1
				
					roomInfo.room.messages = roomInfo.messages
					for msg in roomInfo.room.messages
						index = $scope.allUsers.map (e)->
							e.id
						.indexOf msg.userId

						msg.user = angular.copy $scope.allUsers[index]
					$scope.rooms.push roomInfo.room

				$mode.change 'list'

			else if newvalue.event == 'ON_WS_OPEN'
				if newvalue.online instanceof Array
					logins = angular.copy newvalue.online
					
					for online in logins
						index = $scope.allUsers.map (e)->
							e.login
						.indexOf online.field
						
						if index > -1
							$scope.map.user[$scope.prefix.user+$scope.allUsers[index].id].online = true
				else
					login = angular.copy newvalue.online
				
					index = $scope.allUsers.map (e)->
						e.login
					.indexOf login
					
					if index > -1
						$scope.map.user[$scope.prefix.user+$scope.allUsers[index].id].online = true
			
			else if newvalue.event == 'ON_WS_CLOSE'
				login = angular.copy newvalue.offline
				
				index = $scope.allUsers.map (e)->
					e.login
				.indexOf login
				
				if index > -1
					$scope.map.user[$scope.prefix.user+$scope.allUsers[index].id].online = false
			
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

				$scope.map.user[$scope.prefix.user+user.id] = angular.copy user
				$scope.map.user[$scope.prefix.user+user.id].online = false

				getAvailableUsers()

			else if newvalue.event == 'EDIT_USER'
				user = angular.copy newvalue.user
				
				index = $scope.allUsers.map (e)->
					e.id
				.indexOf user.id
				
				$scope.allUsers[index].name = user.name
				$scope.map.user[$scope.prefix.user+user.id].name = user.name

			else if newvalue.event == 'REMOVE_USER'
				index = $scope.allUsers.map (e)->
					e.id
				.indexOf newvalue.userId

				$scope.allUsers.splice index, 1
				$scope.map.user[$scope.prefix.user+newvalue.userId] = null # TODO: delete it instead

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
				
				if newvalue.userId == $scope.thisUserId
					$scope.map.access[$scope.prefix.access+newvalue.roomId] = true

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

				if newvalue.userId == $scope.thisUserId
					$scope.map.access[$scope.prefix.access+newvalue.roomId] = false
				
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

	$scope.$watch  ->
		$cookies.get 'auth'
	,
		(newvalue,oldvalue)->
			if not newvalue
				Messages.close()

	return
]