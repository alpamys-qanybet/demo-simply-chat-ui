// Generated by CoffeeScript 1.4.0
(function() {

  angular.module('ibnsina').controller('RegisterCtrl', [
    '$scope', '$rootScope', '$api', '$auth', '$mode', function($scope, $rootScope, $api, $auth, $mode) {
      $rootScope.current = 'register';
      $scope.model = {
        login: null,
        name: null,
        password: null
      };
      $mode.change('register');
      $scope.register = function() {
        var plain;
        plain = {
          login: $scope.model.login,
          name: $scope.model.name
        };
        $api.openapi.register(plain, function(data) {
          if (!data.field.value) {
            $scope.loginNotAvailable = true;
          } else {
            $scope.model.password = data.field.value;
            $mode.change('signin');
          }
        });
      };
    }
  ]);

}).call(this);
