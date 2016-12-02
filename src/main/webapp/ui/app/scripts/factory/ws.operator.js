angular.module('ibnsina').factory('Messages', function($websocket) {
  // var ws = $websocket('ws://echo.websocket.org/');
  // var ws = $websocket("ws://192.168.100.14:8080/api/operdisp/777");
  var ws = $websocket("ws://"+domainHost+"/api/operator/777");
  var collection = [];
  var response = [];

  ws.onMessage(function(event) {
    // console.log('message: ', event);
    var res;
    try {
      res = JSON.parse(event.data);
    } catch(e) {
      res = {'username': 'anonymous', 'message': event.data};
    }

    // collection.push({
    //   username: res.username,
    //   content: res.message,
    //   timeStamp: event.timeStamp
    // });

  	response['queue'] = res;
  	// collection.length = 0; // I need only one element, object instead of array not works
  	// collection.push(res);
  });

  ws.onError(function(event) {
    console.log('connection Error', event);
  });

  ws.onClose(function(event) {
    console.log('connection closed', event);
    window.location.reload();
  });

  ws.onOpen(function() {
    console.log('connection open');
    // ws.send('Hello World');
    // ws.send('again');
    // ws.send('and again');
  });
  // setTimeout(function() {
  //   ws.close();
  // }, 500)

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