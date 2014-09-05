// Generated by IcedCoffeeScript 1.7.1-f
(function() {
  var controllers, tim_chat;

  tim_chat = angular.module("tim_chat", ["ngSanitize", "ngCookies"]);

  controllers = {};

  controllers.my_controller = function($scope, $http, $interval, $sanitize, $cookies) {
    return $scope.init = function() {
      $scope.safe_input = function(input) {
        var error;
        try {
          $sanitize(input);
          return input;
        } catch (_error) {
          error = _error;
          return $("<div />").text(input).html();
        }
      };
      $scope.bullet = $.bullet("ws://" + location.host + "/bullet");
      $scope.bullet.onopen = function() {
        var mess;
        mess = {
          "type": "update_username",
          "content": $scope.safe_input($scope.username)
        };
        $scope.bullet.send(JSON.stringify(mess));
        mess = {
          "type": "get_history",
          "content": "null"
        };
        $scope.bullet.send(JSON.stringify(mess));
        return console.log("bullet: connected");
      };
      $scope.bullet.ondisconnect = function() {
        return console.log("bullet: disconnected");
      };
      $scope.bullet.onclose = function() {
        return console.log("bullet: closed");
      };
      $scope.bullet.onmessage = function(e) {
        var mess;
        mess = $.parseJSON(e.data);
        if (mess.type === "error") {
          alert(mess.content);
        }
        if (mess.type === "update_username") {
          $cookies.username = mess.content;
          $scope.username = mess.content;
          $scope.greeting = $sanitize("<p>Hi, " + ($scope.safe_input($scope.username)) + "!</p>");
        }
        if (mess.type === "update_userlist") {
          $scope.userlist = mess.content;
        }
        if (mess.type === "add_message") {
          $scope.messages = "" + ($sanitize(mess.content)) + $scope.messages;
        }
        if (mess.type === "set_history") {
          return $scope.messages = mess.content;
        }
      };
      $scope.bullet.onheartbeat = function() {
        var mess;
        mess = {
          "type": "ping",
          "content": $scope.safe_input($scope.username)
        };
        return $scope.bullet.send(JSON.stringify(mess));
      };
      if ($cookies.username === void 0) {
        $cookies.username = "anon";
      }
      $scope.username = $cookies.username;
      $scope.greeting = $sanitize("<p>Hi, " + ($scope.safe_input($scope.username)) + "!</p>");
      $scope.log_in = function() {
        var mess;
        if ($scope.new_username !== void 0) {
          mess = {
            "type": "update_username",
            "content": $scope.safe_input($scope.new_username)
          };
          $scope.bullet.send(JSON.stringify(mess));
          return $scope.new_username = void 0;
        }
      };
      $scope.log_out = function() {
        var mess;
        mess = {
          "type": "ping",
          "content": "anon"
        };
        $scope.bullet.send(JSON.stringify(mess));
        return $scope.new_username = void 0;
      };
      $scope.send_message = function() {
        var content, mess;
        if ($scope.new_message !== void 0) {
          content = {};
          content.message = $scope.safe_input($scope.new_message);
          content.autor = $scope.safe_input($scope.username);
          mess = {
            "type": "text_mesage",
            "content": content
          };
          $scope.bullet.send(JSON.stringify(mess));
          return $scope.new_message = void 0;
        }
      };
      $scope.keypress_handler = function($event) {
        if ($event.which === 13) {
          $event.preventDefault();
          return $scope.send_message();
        }
      };
      return $interval((function() {}), 500, [], []);
    };
  };

  tim_chat.controller(controllers);

}).call(this);
