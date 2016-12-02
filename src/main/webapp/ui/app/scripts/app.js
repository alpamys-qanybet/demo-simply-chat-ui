// var domainHost = 'alpamys-samsung:8080';
var domainHost = 'localhost:8080';
var domainURL = 'http://'+domainHost;
//var domainURL = window.location.origin;
//var domainHost = domainURL.substr(7);

angular.module('ibnsina', ['ui.router', 'restangular', 'ngCookies', 'ngSanitize', 'cgNotify', 'ngWebSocket'])
	.config(['RestangularProvider', function(RestangularProvider) {
		RestangularProvider.setBaseUrl(domainURL+'/api/rest/');
		RestangularProvider.setDefaultHeaders( {'content-type': 'application/json; charset=utf-8'});
		RestangularProvider.setRequestInterceptor(function(elem, operation) {
			if (operation === "remove") {
				return undefined;
			} 
			return elem;
		})
		RestangularProvider.addResponseInterceptor(function (data, operation, what, url, response, deferred) {
			var autologout = response.headers()['content-type'];
			if (autologout == 'text/html') {
				return window.location = domainURL+'/api/login.html';
			}
			return response.data;
		});
	}])
	.config(['$stateProvider', function($stateProvider) {
		$stateProvider
        .state('register', {
            url: '/register',
            templateUrl: 'views/register.html',
            controller: 'RegisterCtrl'
        })
        .state('room', {
            url: '/room',
            templateUrl: 'views/room/room.list.html',
            controller: 'RoomCtrl'
        })
		.state('room.add', {
            url: '/add',
            templateUrl: 'views/room/room.add.html'
        })
		.state('room.view', {
            url: '/view/:roomId',
            templateUrl: 'views/room/room.view.html'
        })
        .state('room.view.users', {
            url: '/users',
            templateUrl: 'views/room/room.view.users.html'
        });
	}])
	.run(['$rootScope', '$state', '$stateParams', 'notify', '$cookies', function($rootScope, $state, $stateParams, notify, $cookies) {
		$rootScope.$state = $state;
		$rootScope.$stateParams = $stateParams;
		$rootScope.$cookies = $cookies;

		notify.config({
			duration: 7800,
			position: 'right'
		});

		$rootScope.notify = notify;
		$rootScope.covering = true;
	}]);