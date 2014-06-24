
			function f_go(page)
			{
                f_new();
                var str="page_";
                str+=page;
                document.getElementById(str).style.display = "block";                
			}
			function f_new()
			{
				for(var i=1;i<8;i++)
				{
                    var str="page_";
                    str+=i;
                    document.getElementById(str).style.display = "none";
				}
			}
