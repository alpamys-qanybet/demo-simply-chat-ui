// Generated by CoffeeScript 1.4.0
(function() {

  angular.module('ibnsina').controller('RoomCtrl', [
    '$scope', '$state', '$rootScope', '$api', 'MessagesMonitoring', '$security', '$mode', '$cookies', function($scope, $state, $rootScope, $api, Messages, $security, $mode, $cookies) {
      var fetchRoomUsers, getAvailableUsers, init, pureModel;
      $rootScope.current = 'room';
      $scope.thisUserId = Number($cookies.get('userId'));
      $scope.allUsers = [];
      $scope.prefix = {
        user: 'u',
        access: 'ra'
      };
      $scope.map = {
        user: [],
        access: []
      };
      pureModel = {
        room: {
          add: {
            id: null,
            name: null
          },
          edit: {
            id: null,
            name: null
          }
        },
        select: {
          operator: null
        }
      };
      $scope.model = angular.copy(pureModel);
      init = function() {
        $scope.model = angular.copy(pureModel);
      };
      $scope.preAdd = function() {
        init();
        $mode.change('add');
      };
      getAvailableUsers = function() {
        var index, indexInUsers, user, _i, _len, _ref;
        if (!$scope.model.room.edit.id) {
          return;
        }
        $scope.users = [];
        _ref = $scope.allUsers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          user = _ref[_i];
          index = $scope.model.room.edit.users.map(function(e) {
            return e.id;
          }).indexOf(user.id);
          indexInUsers = $scope.users.map(function(e) {
            return e.id;
          }).indexOf(user.id);
          if (index === -1 && indexInUsers === -1) {
            $scope.users.push(user);
          }
        }
        if ($scope.users.length > 0) {
          $scope.model.select.user = $scope.users[0].id;
        }
      };
      fetchRoomUsers = function(id) {
        $rootScope.loading = true;
        $api.room.users.list(id, function(data) {
          $rootScope.loading = false;
          $scope.model.room.edit.users = data;
        });
      };
      $scope.add = function() {
        var plain;
        plain = {
          name: $scope.model.room.add.name
        };
        $rootScope.loading = true;
        $api.room.create(plain, function(data) {
          $rootScope.loading = false;
          $mode.change('list');
        });
      };
      $scope.edit = function() {
        var plain;
        plain = {
          id: $scope.model.room.edit.id,
          name: $scope.model.room.edit.name
        };
        $rootScope.loading = true;
        $api.room.update(plain, function(data) {
          $rootScope.loading = false;
          $mode.change('list');
        });
      };
      $scope.select = function(room) {
        $scope.model.room.edit = room;
        getAvailableUsers();
        $mode.change('view');
      };
      $scope.addUser = function(userId, roomId) {
        var id, plain;
        id = roomId;
        plain = {
          id: userId
        };
        $rootScope.loading = true;
        $api.room.users.create(id, plain, function(data) {
          $rootScope.loading = false;
          fetchRoomUsers(id);
        });
      };
      $scope.removeUser = function(userId, roomId) {
        var id;
        id = roomId;
        $rootScope.loading = true;
        $api.room.users["delete"](id, userId, function(data) {
          $rootScope.loading = false;
          fetchRoomUsers(id);
        });
      };
      $scope.removeRoom = function() {
        var id;
        id = $scope.model.room.edit.id;
        $rootScope.loading = true;
        $api.room["delete"](id, function(data) {
          $rootScope.loading = false;
          $mode.change('list');
        });
      };
      $scope.sendMessage = function() {
        var plain;
        plain = {
          content: $scope.model.msg,
          roomId: $scope.model.room.edit.id,
          userId: $cookies.get('userId')
        };
        $api.room.users.message.send(plain, function(data) {
          $scope.model.msg = null;
          $rootScope.loading = false;
        });
      };
      $scope.Messages = Messages;
      $scope.$watch(function() {
        return $scope.Messages.response['queue'];
      }, function(newvalue, oldvalue) {
        var accessToChatRoomIndex, index, indexInsideRoom, indexRoom, login, logins, msg, online, room, roomInfo, rooms, u, user, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2;
        if (newvalue.event === 'LAUNCH_INFO') {
          init();
          $scope.rooms = [];
          $scope.allUsers = newvalue.users;
          _ref = $scope.allUsers;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            u = _ref[_i];
            $scope.map.user[$scope.prefix.user + u.id] = angular.copy(u);
            $scope.map.user[$scope.prefix.user + u.id].online = false;
          }
          rooms = angular.copy(newvalue.rooms);
          for (_j = 0, _len1 = rooms.length; _j < _len1; _j++) {
            roomInfo = rooms[_j];
            roomInfo.room.users = roomInfo.users;
            accessToChatRoomIndex = roomInfo.room.users.map(function(e) {
              return e.id;
            }).indexOf($scope.thisUserId);
            $scope.map.access[$scope.prefix.access + roomInfo.room.id] = accessToChatRoomIndex > -1;
            roomInfo.room.messages = roomInfo.messages;
            _ref1 = roomInfo.room.messages;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              msg = _ref1[_k];
              index = $scope.allUsers.map(function(e) {
                return e.id;
              }).indexOf(msg.userId);
              msg.user = angular.copy($scope.allUsers[index]);
            }
            $scope.rooms.push(roomInfo.room);
          }
          $mode.change('list');
        } else if (newvalue.event === 'ON_WS_OPEN') {
          if (newvalue.online instanceof Array) {
            logins = angular.copy(newvalue.online);
            for (_l = 0, _len3 = logins.length; _l < _len3; _l++) {
              online = logins[_l];
              index = $scope.allUsers.map(function(e) {
                return e.login;
              }).indexOf(online.field);
              if (index > -1) {
                $scope.map.user[$scope.prefix.user + $scope.allUsers[index].id].online = true;
              }
            }
          } else {
            login = angular.copy(newvalue.online);
            index = $scope.allUsers.map(function(e) {
              return e.login;
            }).indexOf(login);
            if (index > -1) {
              $scope.map.user[$scope.prefix.user + $scope.allUsers[index].id].online = true;
            }
          }
        } else if (newvalue.event === 'ON_WS_CLOSE') {
          login = angular.copy(newvalue.offline);
          index = $scope.allUsers.map(function(e) {
            return e.login;
          }).indexOf(login);
          if (index > -1) {
            $scope.map.user[$scope.prefix.user + $scope.allUsers[index].id].online = false;
          }
        } else if (newvalue.event === 'ADD_ROOM') {
          room = angular.copy(newvalue.room);
          room.messages = [];
          room.users = [];
          $scope.rooms.push(room);
        } else if (newvalue.event === 'EDIT_ROOM') {
          room = angular.copy(newvalue.room);
          index = $scope.rooms.map(function(e) {
            return e.id;
          }).indexOf(room.id);
          $scope.rooms[index].name = room.name;
        } else if (newvalue.event === 'REMOVE_ROOM') {
          index = $scope.rooms.map(function(e) {
            return e.id;
          }).indexOf(newvalue.roomId);
          $scope.rooms.splice(index, 1);
          getAvailableUsers();
          if ($scope.model.room.edit.id) {
            if (newvalue.roomId === $scope.model.room.edit.id) {
              $mode.change('list');
            }
          }
        } else if (newvalue.event === 'ADD_USER') {
          user = angular.copy(newvalue.user);
          $scope.allUsers.push(user);
          $scope.map.user[$scope.prefix.user + user.id] = angular.copy(user);
          $scope.map.user[$scope.prefix.user + user.id].online = false;
          getAvailableUsers();
        } else if (newvalue.event === 'EDIT_USER') {
          user = angular.copy(newvalue.user);
          index = $scope.allUsers.map(function(e) {
            return e.id;
          }).indexOf(user.id);
          $scope.allUsers[index].name = user.name;
          $scope.map.user[$scope.prefix.user + user.id].name = user.name;
        } else if (newvalue.event === 'REMOVE_USER') {
          index = $scope.allUsers.map(function(e) {
            return e.id;
          }).indexOf(newvalue.userId);
          $scope.allUsers.splice(index, 1);
          $scope.map.user[$scope.prefix.user + newvalue.userId] = null;
          _ref2 = $scope.rooms;
          for (_m = 0, _len4 = _ref2.length; _m < _len4; _m++) {
            room = _ref2[_m];
            indexInsideRoom = room.users.map(function(e) {
              return e.id;
            }).indexOf(newvalue.userId);
            if (indexInsideRoom > -1) {
              room.users.splice(indexInsideRoom, 1);
            }
          }
          getAvailableUsers();
        } else if (newvalue.event === 'ADD_USER_TO_ROOM') {
          index = $scope.allUsers.map(function(e) {
            return e.id;
          }).indexOf(newvalue.userId);
          indexRoom = $scope.rooms.map(function(e) {
            return e.id;
          }).indexOf(newvalue.roomId);
          $scope.rooms[indexRoom].users.push(angular.copy($scope.allUsers[index]));
          if (newvalue.userId === $scope.thisUserId) {
            $scope.map.access[$scope.prefix.access + newvalue.roomId] = true;
          }
          getAvailableUsers();
        } else if (newvalue.event === 'REMOVE_USER_FROM_ROOM') {
          indexRoom = $scope.rooms.map(function(e) {
            return e.id;
          }).indexOf(newvalue.roomId);
          indexInsideRoom = $scope.rooms[indexRoom].users.map(function(e) {
            return e.id;
          }).indexOf(newvalue.userId);
          if (indexInsideRoom > -1) {
            $scope.rooms[indexRoom].users.splice(indexInsideRoom, 1);
          }
          if (newvalue.userId === $scope.thisUserId) {
            $scope.map.access[$scope.prefix.access + newvalue.roomId] = false;
          }
          getAvailableUsers();
        } else if (newvalue.event === 'MESSAGE_ROOM') {
          msg = angular.copy(newvalue.message);
          indexRoom = $scope.rooms.map(function(e) {
            return e.id;
          }).indexOf(msg.roomId);
          index = $scope.allUsers.map(function(e) {
            return e.id;
          }).indexOf(msg.userId);
          msg.user = angular.copy($scope.allUsers[index]);
          $scope.rooms[indexRoom].messages.push(msg);
        }
      }, true);
      $scope.$watch(function() {
        return $cookies.get('auth');
      }, function(newvalue, oldvalue) {
        if (!newvalue) {
          return Messages.close();
        }
      });
    }
  ]);

}).call(this);
