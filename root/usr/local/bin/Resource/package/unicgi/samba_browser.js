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

function JSP_GetIpAddr()
{
    var url = "/cgi-bin/UniCGI.cgi?id=12";
    createXMLHttpRequest();
    xmlHttp.onreadystatechange = handleStateChange;
    xmlHttp.open("GET", url, true);
    xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}
function handleStateChange()
{
  if(xmlHttp.readyState == 4)
    {
        if(xmlHttp.status == 200)
        {
			var xmlDoc = xmlHttp.responseXML;
			var item=xmlDoc.getElementsByTagName("ITEM");
			var ReturnValue = item[0].getElementsByTagName("return")[0].firstChild.nodeValue;
			window.location="\\\\"+ReturnValue;
		
		//	window.location="file://///"+ReturnValue+"/hdd1";
			
        }
    }
}
