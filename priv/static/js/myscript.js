var tim_chat = angular.module("tim_chat",["ngSanitize", "ngCookies"]);
var controllers = {};

controllers.my_controller = function($scope, $http, $interval, $sanitize, $cookies)
	{
		$scope.init = function()
		{
			// set cookies and username by default if it necessary
			if($cookies.username == undefined)
			{
				$cookies.username = "anon";
			};
			$scope.username = $cookies.username;

			// define func to update username
			$scope.ping_username = function()
			{
				var mess = {"type" : "ping", "content" : $scope.username};
		    	$scope.bullet.send(JSON.stringify(mess));
			};
			$scope.log_in = function()
			{	
				if($scope.new_username != undefined)
				{
					var mess = {"type" : "update_username", "content" : $scope.new_username};
			    	$scope.bullet.send(JSON.stringify(mess));
			    	$scope.new_username = undefined
				}
			};
			$scope.log_out = function()
			{
				var mess = {"type" : "ping", "content" : "anon"};
		    	$scope.bullet.send(JSON.stringify(mess));
		    	$scope.new_username = undefined
			}
			$scope.send_message = function()
			{
				if($scope.new_message != undefined)
				{	
					var content = {}
					content.message = $scope.new_message
					content.autor = $scope.username
					var mess = {"type" : "text_mesage", "content" : content};
					$scope.bullet.send(JSON.stringify(mess));
		    		$scope.new_message = undefined
				}
			}

			// connect bullet 
		    $scope.bullet = $.bullet('ws://176.193.9.127:8080/bullet');
		    // define bullet callbacks
		    $scope.bullet.onopen = function(){

		    	// send username
				var mess = {"type" : "update_username", "content" : $scope.username};
			    $scope.bullet.send(JSON.stringify(mess));
			    mess = {"type" : "get_history", "content" : "null"};
			    $scope.bullet.send(JSON.stringify(mess));
			    console.log('bullet: connected')
		    };	
		    $scope.bullet.ondisconnect = function(){
		        console.log('bullet: disconnected');
		    };
		    $scope.bullet.onclose = function(){
		        console.log('bullet: closed');
		    };
		    $scope.bullet.onmessage = function(e){
		    	var mess = $.parseJSON(e.data);
		    	if(mess.type == "error")
		        {
		        	alert(mess.content);
		        };
		        if(mess.type == "update_username")
		        {
		        	$cookies.username = mess.content;
		        	$scope.username = mess.content;
		        };
		        if(mess.type == "update_userlist")
		        {
		        	$scope.userlist = $sanitize(mess.content);
		        };
		       	if(mess.type == "add_message")
		        {
		        	$scope.messages = $sanitize(mess.content)+$scope.messages;
		        };
		        if(mess.type == "set_history")
		        {
		        	$scope.messages = $sanitize(mess.content);
		        };
		    };
		    // send your nickname to show that you alive
		    $scope.bullet.onheartbeat = function(){
		    	$scope.ping_username();
		    };

			$interval(function(){}, 500, [], []);

		}

	};

tim_chat.controller(controllers);