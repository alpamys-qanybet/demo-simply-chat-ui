// Generated by CoffeeScript 1.4.0
(function() {

  angular.module('ibnsina').controller('MainCtrl', [
    '$scope', '$rootScope', '$auth', '$state', function($scope, $rootScope, $auth, $state) {
      $rootScope.covering = true;
      $rootScope.domain = domainURL;
      $auth.authorized(function() {
        $auth.authenticate();
      }, function() {
        $state.transitionTo('register');
      });
      $scope.navs = [
        {
          name: 'users',
          url: 'users',
          label: 'users',
          icon: 'fa-user-plus'
        }, {
          name: 'lines',
          url: 'line',
          label: 'lines',
          icon: 'fa-bars'
        }, {
          name: 'queue',
          url: 'queue',
          label: 'queue',
          icon: 'fa-exchange'
        }
      ];
      $rootScope.currentUrl = function() {
        return document.URL;
      };
    }
  ]);

}).call(this);
