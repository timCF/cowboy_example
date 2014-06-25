
			function f_go(page)
			{
                f_new();
                var str="page_";
                str+=page;
                document.getElementById(str).style.display = "block";                
			};
			function f_new()
			{
				for(var i=1;i<8;i++)
				{
                    var str="page_";
                    str+=i;
                    document.getElementById(str).style.display = "none";
				}
			};



		    function sendTxt(num) {
	            txt = document.getElementById("send_txt"+num).value;
	            httpGet("http://localhost:8080/query/?text="+encodeURIComponent(txt)); 
		    };
	      	function httpGet(theUrl)
			{
			    var xmlHttp = null;

			    xmlHttp = new XMLHttpRequest();
			    xmlHttp.open( "GET", theUrl, false );
			    xmlHttp.send( null );
			    return xmlHttp.responseText;
			}