var xmlHttp;
function createXMLHttpRequest()
{
    if (window.ActiveXObject)
    {
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    } 
    else if (window.XMLHttpRequest)
    {
        xmlHttp = new XMLHttpRequest();
    }
}

function JSP_Input_Pass()
{
  //	if(event.keyCode==13){
		//var tmp = document.getElementById("password2_lable");
		//tmp.disabled = false;
		//tmp.style.color = "black";
		
		var tmp = document.getElementById("password2");
		tmp.disabled = false;
		tmp.value= "";
		
	//	var tmp = document.getElementById("password_ok");
	//	tmp.disabled = false;
//	}
}

function weblogin()
{
	var username = document.getElementById("username").value;
	var pas = document.getElementById("password").value;
	
	if((username=="")||(pas==""))
	{
		alert("Please enter username and password\n");
		return false;
	}
	var url = "/cgi-bin/UniCGI.cgi?id=9&check_auth=0&username="+username+"&password="+pas;
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleLogin;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);	
	return true;
}
function handleLogin()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			var xmlDoc = xmlHttp.responseXML;
			var operation = xmlDoc.getElementsByTagName("operation").item(0);
			var ret = operation.getElementsByTagName("return");
			var retVal = ret[0].firstChild.nodeValue;
			if (retVal != "OK")
			{
				alert(retVal);
				return;
			}
			else
			{
				window.location="./home.html";				
			}
		}
	}
}

function handleCheckSecurity()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			var xmlDoc = xmlHttp.responseXML;
			
			var operation = xmlDoc.getElementsByTagName("operation").item(0);
			var ret = operation.getElementsByTagName("return");
			var retVal = ret[0].firstChild.nodeValue;
			
			if (retVal == "YES")
			{
				return;
			}
			else
			{
				window.location="./home.html";				
			}
		}
	}
}

function check_security()
{
	var url = "/cgi-bin/UniCGI.cgi?id=9&check_auth=1";
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleCheckSecurity;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);	
}


function JSP_Input_Pass2()
{
//	if(event.keyCode==13){
		JSP_Submit_Pass();
//	}
}

function JSP_Submit_Pass()
{
	var pas1 = document.getElementById("password").value;
	var pas2 = document.getElementById("password2").value;
          
   
	if((pas1 != pas2)){
		alert("password not match");
	}else
	if(pas1=="")
		alert("password can't be null");
	else{
		JSP_Modify_PowerUser_Password( pas1);
	}
	
	document.getElementById("password").value= "";
	//var tmp = document.getElementById("password2_lable");
	//tmp.disabled = true;
	//tmp.style.color = "gray";
	var tmp = document.getElementById("password2");
	//tmp.disabled = true;
	tmp.value= "";
	//var tmp = document.getElementById("password_ok");
	//tmp.disabled = true;
}

function JSP_Add_User(username,passwd)
{
    var url = "/cgi-bin/UniCGI.cgi?id=8";
    createXMLHttpRequest();
    xmlHttp.onreadystatechange = handleAdduser;
    xmlHttp.open("POST", url, true);
    xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
    var urlparam = "action=0&username=" + username + "&passwd=" + passwd;
    xmlHttp.send(urlparam);
}


function JSP_Modify_PowerUser_Password(pas)
{
	JSP_Add_User("admin",pas);
 	var url = "/cgi-bin/UniCGI.cgi?id=11";
    createXMLHttpRequest();
    xmlHttp.onreadystatechange = handleStateChange;
    xmlHttp.open("POST", url, true);
    xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
    var urlparam = "newpass=" + pas ;
    xmlHttp.send(urlparam);
}

function handleStateChange()
{
    var xmlDoc = xmlHttp.responseXML;
	var item=xmlDoc.getElementsByTagName("operation");
	var ReturnValue = item[0].getElementsByTagName("return")[0].firstChild.nodeValue;

	if( ReturnValue == "OK"){
		alert("Change Power User Password Succeed");
	}
	else{
		alert("Change Power User Password Failed");
	}
	
	window.location.href='./home.html';
}

function handleAdduser()
{
	return;
}
