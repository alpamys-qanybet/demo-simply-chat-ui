'use strict';
/*jshint sub:true*/

angular.module('ibnsina')
.controller('UserProfileCtrl',
	['$scope', '$state','$rootScope', '$stateParams', 'Restangular', 'notify', '$timeout', '$mode', '$api', '$security',
	function($scope, $state, $rootScope, $stateParams, Restangular, notify, $timeout, $mode, $api, $security) {
		console.log('UserProfileCtrl');
		$rootScope.current = 'users';


		/*if ($rootScope.cookies.userId !== $stateParams.userId) {
			$scope.loadSecurity(function() {
				var hasUploadPermission = $scope.hasPermission({'action': 'write', 'target': 'UserManagement'});
				if (!hasUploadPermission) {
					$state.transitionTo('error-access');
				}
			});
		}*/

		$scope.current = {
			id: $stateParams.userId
		};

		var userRest = Restangular.one('secure/users', $scope.current.id);

		$scope.model = {
			user: {
				name: null,
				password: {
					old: null,
					current: null,
					confirm: null
				},
				roles: []
			}
		};

		function fetch () {
			userRest.get().then(function(data) {
				$scope.user = data;

				Restangular.one('secure/users/'+$scope.current.id+'/roles').getList().then(function(rolesData) {
					var roles = [];
					angular.forEach(rolesData, function(role) {
						roles.push(role.name);
					});

					$scope.model.user = {
						id: $scope.user.id,
						name: $scope.user.name,
						roles: roles
					};

					fetchRoles();
				});
			});
		}

		fetch();

		$scope.roles = [];

		function fetchRoles() {
			Restangular.one('secure/roles').get().then(function(data) {
				
				var roles = [];
				angular.forEach(data, function(role) {
					var findIndex = $scope.model.user.roles.indexOf(role.field.value);
					if (findIndex === -1) {
						roles.push(role.field.value);
					}
				});

				$scope.roles = roles;

				$mode.change('view');
			});	
		};

		$scope.addRole = function(role) {
			console.log('addRole ' + role);

			Restangular.all('secure/users/'+$scope.current.id+'/roles').post({name: role}).then(function(data) {
				notify({
					message: 'Success',
					classes: 'alert-success'
				});

				fetch();
			});
		};

		$scope.removeRole = function(role) {
			console.log('addRole ' + role);

			Restangular.one('secure/users/'+$scope.current.id+'/roles/'+role).remove({}).then(function(data) {
				notify({
					message: 'Success',
					classes: 'alert-success'
				});

				fetch();
			});
		};

		$scope.edit = function(user) {
			console.log(user);

			var putUser = userRest;
			putUser.name = user.name;

			putUser.put().then(function(data) {
				// fetch();
				$scope.back();
			});
		};

		$scope.delete = function() {
			if (confirm('delete?')) {
				$api.user.delete($scope.current.id, function(){
					$state.transitionTo('users');
				});
				
				// userRest.remove({}).then(function(){
				// 	$state.transitionTo('users');
				// });
			}
		};

		$scope.changePassword = function() {

			if ($scope.model.user.password.current !== $scope.model.user.password.confirm) {
				console.log('confirm mismatch');
				notify({
					message: 'Confirm mismatch',
					classes: 'alert-warning'
				});
				return;
			}

			var reqobj = {
				password: $scope.model.user.password.confirm,
				old: $scope.model.user.password.old
			};

			Restangular.one('secure/users/password/change')
			.customPUT(reqobj)
			.then(
				function(result) {
					if (result.field.value) {
						notify({
							message: 'Password successfully changed',
							classes: 'alert-success'
						});

						notify({
							message: 'Logging out, please login to check changes',
							classes: 'alert-info'
						});

						$timeout($rootScope.logout, 3000);
					}
					else {
						console.log('password is not correct');
						notify({
							message: 'Current password is not correct',
							classes: 'alert-warning'
						});
					}
				}
			);
		};

		$scope.resetPassword = function() {
			Restangular.one('secure/users/'+$scope.current.id+'/password/reset')
			.get()
			.then(
				function(result) {
					console.log('success ' + result);
				},
				function() {
					console.log('error');
				}
			);
		};

		$scope.back = function() {
			console.log('back')

			$security.loadSecurity(function() {
				var isAdmin = $security.hasRole('ADMIN');
				var isManager = $security.hasRole('MANAGER');
				var isOperator = $security.hasRole('OPERATOR');
				var isHead = $security.hasRole('HEAD');
				var isRegistrator = $security.hasRole('REGISTRATOR');
				if (isOperator) {
					return $state.transitionTo('queue');
				} else if (isAdmin) {
					// return $state.transitionTo('users');
					$mode.change('list');
				} else if (isManager) {
					return $state.transitionTo('line');
					// $mode.change('list');
				} else if (isHead) {
					return $state.transitionTo('report');
				} else if (isRegistrator) {
					return $state.transitionTo('appintegrate');
				}
			});
		};

		$scope.cancelEdit = function() {
			var isAdmin = $security.hasRole('ADMIN');
			var isManager = $security.hasRole('MANAGER');
			var isOperator = $security.hasRole('OPERATOR');
			var isHead = $security.hasRole('HEAD');
			var isRegistrator = $security.hasRole('REGISTRATOR');
			if (isOperator) {
				return $state.transitionTo('queue');
			} else if (isAdmin) {
				// return $state.transitionTo('users');
				$mode.change('view');
			} else if (isManager) {
				return $state.transitionTo('line');
				// $mode.change('list');
			} else if (isHead) {
				return $state.transitionTo('report');
			} else if (isRegistrator) {
				return $state.transitionTo('appintegrate');
			}
		};
	}]);
