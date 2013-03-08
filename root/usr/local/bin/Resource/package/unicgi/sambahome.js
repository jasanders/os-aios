var xmlHttp;
var torrentInterval = 0;
var highli = -1;

var buf=new Array();

var path=new Array();
var ipaddr;


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




function clearPrevTable()
{
	var torrenttbody = document.getElementById("torrenttbody");
	while(torrenttbody.childNodes.length > 0)
	{
		torrenttbody.removeChild(torrenttbody.childNodes[0]);
	}
}

function createEmptyRow(id)
{
	var row = document.createElement("tr");
	/* No. */
	var cell = document.createElement("td");
	var textNode = document.createTextNode(id);
	cell.appendChild(textNode);
	cell.setAttribute("width", "35");
	cell.style.color = "#FFFFFF";
	row.appendChild(cell);
	
	cell = document.createElement("td");
	textNode = document.createTextNode("------");
	cell.appendChild(textNode);
	cell.setAttribute("width", "182");
	cell.style.color = "#FFFFFF";
	row.appendChild(cell);
	
	cell = document.createElement("td");
	textNode = document.createTextNode("------");
	cell.appendChild(textNode);
	cell.setAttribute("width", "107");
	cell.style.color = "#FFFFFF";
	row.appendChild(cell);	
	
	cell = document.createElement("td");
	textNode = document.createTextNode("------");
	cell.appendChild(textNode);
	cell.setAttribute("width", "267");
	cell.style.color = "#FFFFFF";
	row.appendChild(cell);	
	
	cell = document.createElement("td");
	textNode = document.createTextNode("------");
	cell.appendChild(textNode);
	cell.setAttribute("width", "53");
	cell.style.color = "#FFFFFF";
	row.appendChild(cell);	

	cell = document.createElement("td");
	textNode = document.createTextNode("------");
	cell.appendChild(textNode);
	cell.setAttribute("width", "107");
	cell.style.color = "#FFFFFF";
	row.appendChild(cell);	
	
	return row;
}

function onCheckClick(index,id)
{
	var checkbt = document.getElementsByTagName("input");
	var ind = Number(index);
	for (var outi=0; outi < checkbt.length; outi++)
	{
		if ((checkbt[outi].type=="checkbox") && (checkbt[outi].name=="btcheck"))
		{
				if (checkbt[outi].checked === true)
				{
					clearInterval(torrentInterval);
					torrentInterval = 0;
					document.getElementById("btStart").disabled=false;
					document.getElementById("btStop").disabled=false;
					document.getElementById("btDelete").disabled=false;
					/*
					enablehref(btStart,startTorrent);
					enablehref(btStop,stopTorrent);
					enablehref(btDelete,deleteTorrent);
					*/
					return;
				}
		}
	}
	//torrentInterval = setInterval("updateAllInfo()", 10000);
	document.getElementById("btStart").disabled=true;
	document.getElementById("btStop").disabled=true;		
	document.getElementById("btDelete").disabled=true;	
	/*
	disablehref(btStart);
	disablehref(btStop);
	disablehref(btDelete);
	*/
}

function responseTorrentCommand()
{
	var xmlDoc = xmlHttp.responseXML;
	var operation = xmlDoc.getElementsByTagName("operation").item(0);
	var ret = operation.getElementsByTagName("return");
	var retVal = ret[0].firstChild.nodeValue;

	
	//document.getElementById("torrenttable").setAttribute("border", "1");
	
	if (retVal != "OK")
	{
		if (retVal == "logerr")
		{
			window.location="./index.html";
		}
		var torrenttbody = document.getElementById("torrenttbody");
		for (var i=0; i < 5; i++)
		{
			row = createEmptyRow(i+1);
			torrenttbody.appendChild(row);
		}
		  
		return;
	}

			var authen = xmlDoc.getElementsByTagName("Auth");
		//	ipaddr = authen[0].firstChild.nodeValue;

			thisUrl=document.URL;
			thisUrl11=thisUrl.substring(7);
			endIndex=thisUrl11.indexOf("/");
			ipaddr=thisUrl11.substring(0,endIndex);

	
	{
		var usbItems = xmlDoc.getElementsByTagName("Usb");		
		//var total = usb.getElementsByTagName("total")[0].firstChild.nodeValue;
		var total=usbItems.length;

		if (total == "0")
		{
			torrenttbody = document.getElementById("torrenttbody");
			for (i=0; i < 5; i++)
			{
				row = createEmptyRow(i+1);
				torrenttbody.appendChild(row);
			}


			return;		
		}
		else
		{
			var usbs = xmlDoc.getElementsByTagName("Usb");
			torrenttbody = document.getElementById("torrenttbody");

			for (i = 0; i < usbs.length; i++)
			{

                           	var UsbPath=usbs[i].getElementsByTagName("UsbPath")[0].firstChild.nodeValue;
			 	path[i]=UsbPath;

				var status_color="#FFFFFF";
					
				var row = document.createElement("tr");
				row.setAttribute("id",i);

				/* Samba list name */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(UsbPath);
				cell.appendChild(textNode);
				cell.setAttribute("width", "182");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color =status_color;
				cell.style.overflow="hidden";
				row.appendChild(cell);
				
				
				torrenttbody.appendChild(row);
			}
		

			return;					
		}
	}

}

function showTorrentStatus()
{
	
	var url = "/cgi-bin/UniCGI.cgi?id=13";
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleTorrentChange;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}

function handleTorrentChange()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			clearPrevTable();
			responseTorrentCommand();
		}
	}
}




function changeHighlight(evt)
{
	var event = evt ? evt : (window.event ? window.event : null);
	
	var srcEle = event.srcElement ? event.srcElement : event.target;
	var parentEle = srcEle.parentElement ? srcEle.parentElement : srcEle.parentNode;
	if (srcEle.tagName == 'TD' && parentEle.tagName == 'TR')
	{
		if (!parentEle.id)
		{
			return;
		}
	    if(document.all) 
		{
	        var torrenttable = document.getElementById("torrenttable").children[0]; 
		}
	    else 
		{
	        var torrenttable = document.getElementById("torrenttable"); 
		}
			
		var tr_list = torrenttable.getElementsByTagName('tr');
		for (i = 0; i < tr_list.length; i++)
		{
			tr_list[i].style.backgroundColor = "black";
		}
		var rowid = Number(parentEle.id);
	//	alert(path[rowid]);

	
		tr_list[rowid].style.backgroundColor = "#999999";
		highli = rowid;

	var osType=getOs();
	if(osType=="MSIE")
		window.location="\\\\"+ipaddr+"\\"+path[rowid];
	else if(osType=="Firefox")
		{
		  var tipstr="file://///"+ipaddr+"/"+path[rowid];
		  alert("Firefox not support direct into samba page,you can enter in new page with url : "+tipstr);
		}
	else if(osType=="Opera")
		{
		  var tipstr="file://"+ipaddr+"/"+path[rowid];
		  alert("Opera not support direct into samba page ,you can enter in new page with url : "+tipstr);
		}
	else
		alert(osType+"  not support direct into samba page!");

	}
}




function getOs()
{
    var OsObject = "";
   if(navigator.userAgent.indexOf("MSIE")>0) {
        return "MSIE";
   }
   if(navigator.userAgent.indexOf("Presto")>0) {
        return "Opera";
   }   
   if(isFirefox=navigator.userAgent.indexOf("Firefox")>0){
        return "Firefox";
   }
   if(isSafari=navigator.userAgent.indexOf("Safari")>0) {
        return "Safari";
   } 
   if(isCamino=navigator.userAgent.indexOf("Camino")>0){
        return "Camino";
   }
   if(isMozilla=navigator.userAgent.indexOf("Gecko/")>0){
        return "Gecko";
   } 
}
