angular.module('ibnsina').factory('MessagesMonitoring', function($websocket) {
      // var ws = $websocket('ws://echo.websocket.org/');
      // var ws = $websocket("ws://192.168.1.108:8080/api/monitoring/88");
      var ws = $websocket("ws://"+domainHost+"/api/monitoring/88");
      var response = [];

      ws.onMessage(function(event) {
        // console.log('message: ', event);
        var res;
        try {
          res = JSON.parse(event.data);
        } catch(e) {
          res = {'username': 'anonymous', 'message': event.data};
        }

        response['queue'] = res;
      });

      ws.onError(function(event) {
        console.log('connection Error', event);
        // jQuery('#myapp').html('<img src="images/qtrack-bg.png" style="width: 100%; height:100vh;"/>');
        jQuery('#myapp').html('Connection Lost');
        pingURL();
      });

      ws.onClose(function(event) {
        console.log('connection closed', event);
        // jQuery('#myapp').html('<img src="images/qtrack-bg.png" style="width: 100%; height:100vh;"/>');
        jQuery('#myapp').html('Connection Lost');
        pingURL();
      });

      ws.onOpen(function() {
        console.log('connection open');
      });



      function pingURL() {
        jQuery.ajax({ type : "GET",
          url : domainURL+'/api/rest/displayjsonp',
          crossDomain: true,
          // async: false,
          contentType: "application/json; charset=utf-8",
          dataType: "jsonp",
          jsonpCallback: "jsonpresp",
          timeout: 5000,
          success: function(data){
            setTimeout(function(){
              window.location.reload();
            }, 1000*5 );
          },
          error:function(jqXHR, textStatus, errorThrown){
            setTimeout(function(){
              pingURL();
            }, 1000*5 );
          }
        })
        .done(function (data) {})
        .fail(function (jqXHR, textStatus, errorThrown) {});
      }

      jsonpresp = function(data){
        // alert(data);
      };

      return {
        response: response,
        close: function() {
          ws.close();
        },
        status: function() {
          return ws.readyState;
        },
        send: function(message) {
          if (angular.isString(message)) {
            ws.send(message);
          }
          else if (angular.isObject(message)) {
            ws.send(JSON.stringify(message));
          }
        }
      };
    });