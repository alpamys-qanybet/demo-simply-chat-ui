angular.module('ibnsina').factory('MessagesDisplay', function($websocket, $cookies) {
      // var ws = $websocket("ws://alpamys-samsung:8080/api/operatordisplay/22");
      var ws = $websocket("ws://"+domainHost+"/api/operatordisplay/34");
      var response = [];
      var collection = [];
      var display = null;

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
        var xxDisplay = $cookies.get('display');
        // alert('file:///mnt/sdcard/DCIM/displaychecker/display.html?display='+xxDisplay);
        // return window.location = 'file:///mnt/sdcard/DCIM/displaychecker/display.html?display='+xxDisplay;
        pingURL();
        // return window.location = 'http://192.168.0.103/displaychecker/check.html?display='+xxDisplay;
      });

      ws.onClose(function(event) {
        console.log('connection closed', event);
        var xxDisplay = $cookies.get('display');
        display = xxDisplay;
        pingURL();
        // alert('file:///mnt/sdcard/DCIM/displaychecker/display.html?display='+xxDisplay);
        // return window.location = 'file:///mnt/sdcard/DCIM/displaychecker/display.html?display='+xxDisplay;
        // return window.location = 'http://192.168.0.103/displaychecker/check.html?display='+xxDisplay;
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
            // alert('reply');
            setTimeout(function(){
              window.location.reload();
            }, 1000*5 );
            // window.location = domainURL+'/api/ui/app/display.html#/display/'+display;
            // window.location = 'http://192.168.0.103/app/qtrack/ui/src/main/webapp/ui/app/display.html#/display/'+display;
          },
          error:function(jqXHR, textStatus, errorThrown){
            // alert('timeout/error');
            //handle error here
            setTimeout(function(){
              pingURL();
            }, 1000*5 );
          }
        })
        .done(function (data) {
        }).fail(function (jqXHR, textStatus, errorThrown) {
          // console.log(errorThrown);
          // setTimeout(function(){
          //  pingURL();
          // }, 1000*5 );
        });
      }

      jsonpresp = function(data){
        // alert(data);
      };

      
      return {
        collection: collection,
        response: response,
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