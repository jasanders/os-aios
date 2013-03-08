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

function createCellWithText(text)
{
    var cell = document.createElement("td");
    var textNode = document.createTextNode(text);
    cell.appendChild(textNode);
	cell.setAttribute("align", "center");
	cell.style.backgroundColor = "#CCCCCC";
    return cell;
}

function clearPrevTable()
{
	var storagetbody = document.getElementById("storagetbody");
	while(storagetbody.childNodes.length > 0)
	{
		storagetbody.removeChild(storagetbody.childNodes[0]);
	}
}

function showSystemStatus()
{
	var url = "/cgi-bin/UniCGI.cgi?id=5";
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleSystemStatusChange;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}



function handleSystemStatusChange11()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			var systemdisplay= document.getElementById("systemstatus");
			var bittorrent= document.getElementById("bittorrent");
			var htmlstr;
			var xmlDoc = xmlHttp.responseXML;
			
			var operation = xmlDoc.getElementsByTagName("operation").item(0);
			var ret = operation.getElementsByTagName("return");
			var retVal = ret[0].firstChild.nodeValue;
			
			if (retVal != "OK")
			{
				if (retVal == "logerr")
				{
					window.location="./index.html";
				}
				return;
			}
			
			var authen = xmlDoc.getElementsByTagName("Auth");
			var authenVal = authen[0].firstChild.nodeValue;
			if (authenVal == "NO")
			{
				document.getElementById("account").href="#";
			}
			
			var StatusItems = xmlDoc.getElementsByTagName("StatusItem");
			var StatusTorrent = xmlDoc.getElementsByTagName("StatusTorrent");
			var HDDItems = xmlDoc.getElementsByTagName("Hdd");
			var USBItems = xmlDoc.getElementsByTagName("Usb");
			var item=null;
			
			htmlstr = "";
			for (var i = 0; i < StatusItems.length; i++)
			{
				item = StatusItems[i];
				var name = item.getElementsByTagName("name")[0].firstChild.nodeValue;
				htmlstr = htmlstr + name;
			}
			systemdisplay.innerHTML=htmlstr;
			
			htmlstr = "";
			item = StatusTorrent[0];
			var name = item.getElementsByTagName("name")[0].firstChild.nodeValue;
			htmlstr = htmlstr + name;
			bittorrent.innerHTML=htmlstr;
			
			document.getElementById("storagetable").setAttribute("border", "1");
			clearPrevTable();
			
			//var row = document.createElement("tr");
			//var cell = document.createElement("th");
			//var textNode = document.createTextNode("Hdd Storage");
			//cell.appendChild(textNode);
			//var cell = createCellWithText("Hdd Storage");
			//row.appendChild(cell);
			//cell = document.createElement("th");
			//textNode = document.createTextNode("USB Storage");
			//cell.appendChild(textNode);
			//var cell = createCellWithText("USB Storage");
			//row.appendChild(cell);
			//document.getElementById("storagetbody").appendChild(row);

			var MaxLen;
			//if (HDDItems.length >= USBItems.length)
			//{
				MaxLen = HDDItems.length;
			//}
			//else
			//{
			//	MaxLen = USBItems.length;
			//}

			for (i=0; i<MaxLen; i++)
			{
				var HddIndex;
				var HddFree;
				var UsbIndex;
				var UsbFree;
				var HddText;
				var UsbText;
				if (i < HDDItems.length)
				{
					HddIndex = HDDItems[i].getElementsByTagName("HddIndex")[0].firstChild.nodeValue;	
					HddFree = HDDItems[i].getElementsByTagName("HddFree")[0].firstChild.nodeValue;
					HddText = "HDD"+HddIndex+" free space "+HddFree+"bytes";
				}

				//if (i < USBItems.length)
				//{
				//	UsbIndex = USBItems[i].getElementsByTagName("UsbIndex")[0].firstChild.nodeValue;
				//	UsbFree = USBItems[i].getElementsByTagName("UsbFree")[0].firstChild.nodeValue;
				//	UsbText = "USB"+UsbIndex+" free space "+UsbFree+"bytes";
				//}
				//else
				//{
					UsbText = " ";
				//}
				row = document.createElement("tr");
				cell = createCellWithText(HddText);
				row.appendChild(cell);

				cell = createCellWithText(UsbText);
				row.appendChild(cell);
				document.getElementById("storagetbody").appendChild(row);
			}
		}
	}
}


function handleSystemStatusChange()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			var systemdisplay= document.getElementById("systemstatus");
			var bittorrent= document.getElementById("bittorrent");
			var htmlstr;
			var xmlDoc = xmlHttp.responseXML;
			
			var operation = xmlDoc.getElementsByTagName("operation").item(0);
			var ret = operation.getElementsByTagName("return");
			var retVal = ret[0].firstChild.nodeValue;
			
			if (retVal != "OK")
			{
				if (retVal == "logerr")
				{
					window.location="./index.html";
				}
				return;
			}
			
			var authen = xmlDoc.getElementsByTagName("Auth");
			var authenVal = authen[0].firstChild.nodeValue;
			if (authenVal == "NO")
			{
				document.getElementById("account").href="#";
			}
			
			var StatusItems = xmlDoc.getElementsByTagName("StatusItem");
			var StatusTorrent = xmlDoc.getElementsByTagName("StatusTorrent");
			var HDDItems = xmlDoc.getElementsByTagName("Hdd");
			var USBItems = xmlDoc.getElementsByTagName("Usb");
			var item=null;
			
			htmlstr = "";
			for (var i = 0; i < StatusItems.length; i++)
			{
				item = StatusItems[i];
				var name = item.getElementsByTagName("name")[0].firstChild.nodeValue;
				htmlstr = htmlstr + name;
			}
			systemdisplay.innerHTML=htmlstr;
			
			htmlstr = "";
			item = StatusTorrent[0];
			var name = item.getElementsByTagName("name")[0].firstChild.nodeValue;
			htmlstr = htmlstr + name;
			bittorrent.innerHTML=htmlstr;
			
			document.getElementById("storagetable").setAttribute("border", "1");
			clearPrevTable();
			
			var row = document.createElement("tr");
			var cell = document.createElement("th");
			var textNode = document.createTextNode("Hdd Storage");
			cell.appendChild(textNode);
			//var cell = createCellWithText("Hdd Storage");
			row.appendChild(cell);
			cell = document.createElement("th");
			textNode = document.createTextNode("USB Storage");
			cell.appendChild(textNode);
			//var cell = createCellWithText("USB Storage");
			row.appendChild(cell);
			document.getElementById("storagetbody").appendChild(row);

			var MaxLen;
			if (HDDItems.length >= USBItems.length)
			{
				MaxLen = HDDItems.length;
			}
			else
			{
				MaxLen = USBItems.length;
			}

			for (i=0; i<MaxLen; i++)
			{
				var HddIndex;
				var HddFree;
				var UsbIndex;
				var UsbFree;
				var HddText;
				var UsbText;
				if (i < HDDItems.length)
				{
					HddIndex = HDDItems[i].getElementsByTagName("HddIndex")[0].firstChild.nodeValue;	
					HddFree = HDDItems[i].getElementsByTagName("HddFree")[0].firstChild.nodeValue;
					HddText = "HDD"+HddIndex+" free space "+HddFree+"bytes";
				}
				else
				{
					HddText = " ";
				}
				if (i < USBItems.length)
				{
					UsbIndex = USBItems[i].getElementsByTagName("UsbIndex")[0].firstChild.nodeValue;
					UsbFree = USBItems[i].getElementsByTagName("UsbFree")[0].firstChild.nodeValue;
					UsbText = "USB"+UsbIndex+" free space "+UsbFree+"bytes";
				}
				else
				{
					UsbText = " ";
				}
				row = document.createElement("tr");
				cell = createCellWithText(HddText);
				row.appendChild(cell);
				cell = createCellWithText(UsbText);
				row.appendChild(cell);
				document.getElementById("storagetbody").appendChild(row);
			}
		}
	}
}
