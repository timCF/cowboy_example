tim_chat = angular.module "tim_chat", ["ngSanitize", "ngCookies"] 
controllers = {}


controllers.my_controller = ($scope, $http, $interval, $sanitize, $cookies) ->
	$scope.init = () ->
		# define callbacks for bullet events
		$scope.bullet = $.bullet("ws://#{location.host}/bullet")
		$scope.bullet.onopen = () ->
			mess = {"type" : "update_username", "content" : $scope.safe_input($scope.username)}
			$scope.bullet.send(JSON.stringify(mess))
			mess = {"type" : "get_history", "content" : "null"}
			$scope.bullet.send(JSON.stringify(mess))
			console.log("bullet: connected")
		$scope.bullet.ondisconnect = () ->
	        console.log("bullet: disconnected")
	    $scope.bullet.onclose = () ->
	        console.log("bullet: closed")
	    $scope.bullet.onmessage = (e) ->
	    	mess = $.parseJSON(e.data)
	    	if mess.type == "error" 
	        	alert mess.content 
	        if mess.type == "update_username"
	        	$cookies.username = $scope.safe_input(mess.content)
	        	$scope.username = $scope.safe_input(mess.content)
	        if mess.type == "update_userlist"
	        	$scope.userlist = $scope.safe_input(mess.content) 
	       	if mess.type == "add_message"
	        	$scope.messages = "#{$sanitize($scope.safe_input(mess.content))}#{$scope.messages}"
	        if mess.type == "set_history"
	        	$scope.messages = $scope.safe_input(mess.content) 
	    # send your nickname to show that you alive
	    $scope.bullet.onheartbeat = () ->
	    	mess = {"type" : "ping", "content" : $scope.safe_input($scope.username)}
	    	$scope.bullet.send(JSON.stringify(mess))

		# set cookies and username by default if it necessary
		if $cookies.username == undefined 
			$cookies.username = "anon";
		$scope.username = $cookies.username;

		# define callbacks for user interface
		$scope.log_in = () ->
			if $scope.new_username != undefined 
				mess = {"type" : "update_username", "content" : $scope.safe_input($scope.new_username)}
				$scope.bullet.send(JSON.stringify(mess))
				$scope.new_username = undefined
		$scope.log_out = () ->
			mess = {"type" : "ping", "content" : "anon"}
			$scope.bullet.send(JSON.stringify(mess))
			$scope.new_username = undefined
		$scope.send_message = () ->
			if $scope.new_message != undefined 
				content = {}
				content.message = $scope.safe_input($scope.new_message)
				content.autor = $scope.safe_input($scope.username)
				mess = {"type" : "text_mesage", "content" : content}
				$scope.bullet.send(JSON.stringify(mess))
				$scope.new_message = undefined
		$scope.keypress_handler = ($event) ->
			if $event.which == 13
				$event.preventDefault()
				$scope.send_message()

		# private funcs
		$scope.safe_input = (input) ->
			try
				$sanitize(input)
				input
			catch error
				#alert error
				$("<div />").text(input).html()

		$interval( (->) , 500, [], [])

tim_chat.controller(controllers)