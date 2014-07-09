window.tim_chat = angular.module "tim_chat", ["ngSanitize", "ngCookies"] 
window.controllers = {}
window.tim_chat.directive(	
					'ngEnter',
					(scope, element, attrs) -> 
            			element.bind("keydown keypress", (event) ->
			                if event.which === 13
			                    scope.$apply(() -> scope.$eval(attrs.ngEnter))
			                    event.preventDefault()
            
				)