var xmlHttp;
var torrentInterval = 0;
var highli = -1;

var buf=new Array();


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
//****************************************
/*
function disablehref(id){
	id.onclick=aaa;
}
function aaa(){
	alert("it is disabled right now.do nothing");
	return;
}
function enablehref(id,func){
	id.onclick=func;
}
*/
//*******************************************************

  
   

function responseTorrentDetail()
{
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
	var daemon = xmlDoc.getElementsByTagName("daemon")[0];
	var daemonstatus = daemon.getElementsByTagName("status")[0].firstChild.nodeValue;

	if (daemonstatus == "active")
	{
		var torrent = xmlDoc.getElementsByTagName("torrent")[0];
		var total = torrent.getElementsByTagName("total")[0].firstChild.nodeValue;
		if (total == "0")
		{
			return;		
		}
		else
		{
			var jobs = torrent.getElementsByTagName("job");

		
			for (var i = 0; i < jobs.length; i++)
			{
				//var id = jobs[i].getElementsByTagName("id")[0].firstChild.nodeValue;
				var priority=jobs[i].getElementsByTagName("priority")[0].firstChild.nodeValue;
				var name = jobs[i].getElementsByTagName("name")[0].firstChild.nodeValue;
				var size = jobs[i].getElementsByTagName("size")[0].firstChild.nodeValue;
				var downloaded = jobs[i].getElementsByTagName("downloaded")[0].firstChild.nodeValue;
				var jobstatus = jobs[i].getElementsByTagName("status")[0].firstChild.nodeValue;
				var uprate = jobs[i].getElementsByTagName("uprate")[0].firstChild.nodeValue;
				var timeleft = jobs[i].getElementsByTagName("timeleft")[0].firstChild.nodeValue;
				var storagename = jobs[i].getElementsByTagName("partition")[0].firstChild.nodeValue;

				 
				var j=0;
				while(buf[j++]!=priority)
					;
				priority=j;
	
				
				if (highli < 0)
					highli = 0;
				//document.getElementById("detailNO").innerHTML=highli+1;
				document.getElementById("detailPriority").innerHTML=priority;
				document.getElementById("detailFileName").innerHTML=name;
				document.getElementById("detailStatus").innerHTML=jobstatus;
				document.getElementById("detailSize").innerHTML=downloaded+"M/"+size+"M";
				document.getElementById("detailTimeLeft").innerHTML=timeleft;
				document.getElementById("detailStoragePath").innerHTML=storagename;
				document.getElementById("detailUploadRate").innerHTML=uprate;
			}
			return;					
		}
	}
	else
	{
		return;		
	}	
}

function handleTorrentDetail()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			 
			responseTorrentDetail();
		}
	}
}

function showTorrentDetail(url)
{
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleTorrentDetail;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}

function createCellWithText(text)
{
    var cell = document.createElement("td");
    var textNode = document.createTextNode(text);
    cell.appendChild(textNode);
	cell.style.color = "#FFFFFF";
    return cell;
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
		  
		document.getElementById("btStart").disabled=true;
		document.getElementById("btStop").disabled=true;
		document.getElementById("btDelete").disabled=true;
		document.getElementById("btSetting").disabled=false;
		document.getElementById("btAddNew").disabled=true;
		document.getElementById("btRefresh").disabled=true;
		document.getElementById("btUp").disabled=true;
		document.getElementById("btDown").disabled=true;
		/*
		document.getElementById("btSetting").href="WebTorrentSetting.html";
		document.getElementById("btAddNew").href="#";
		disablehref(btStart);
		disablehref(btStop);
		disablehref(btDelete);
		disablehref(btRefresh);
		disablehref(btUp);
		disablehref(btDown);
		*/
		return;
	}
	var daemon = xmlDoc.getElementsByTagName("daemon")[0];
	var daemonstatus = daemon.getElementsByTagName("status")[0].firstChild.nodeValue;

	if (daemonstatus == "active")
	{
		var torrent = xmlDoc.getElementsByTagName("torrent")[0];		
		var total = torrent.getElementsByTagName("total")[0].firstChild.nodeValue;
		if (total == "0")
		{
			torrenttbody = document.getElementById("torrenttbody");
			for (i=0; i < 5; i++)
			{
				row = createEmptyRow(i+1);
				torrenttbody.appendChild(row);
			}
			document.getElementById("btStart").disabled=true;
			document.getElementById("btStop").disabled=true;
			document.getElementById("btDelete").disabled=true;
			document.getElementById("btSetting").disabled=false;
			document.getElementById("btAddNew").disabled=false;
			document.getElementById("btRefresh").disabled=false;
			document.getElementById("btUp").disabled=true;
			document.getElementById("btDown").disabled=true;
			/*
			document.getElementById("btSetting").href="WebTorrentSetting.html";
			document.getElementById("btAddNew").href="torrentupload.html";
			disablehref(btStart);
			disablehref(btStop);
			disablehref(btDelete);
			enablehref(btRefresh,updateAllInfo);
			disablehref(btUp);
			disablehref(btDown);
			*/
			return;		
		}
		else
		{
			var jobs = torrent.getElementsByTagName("job");
			torrenttbody = document.getElementById("torrenttbody");


 			var max_priority=-1;
 			var tmp_priority;
			var i;
                    for(i=0;i<jobs.length;i++)
                    	{
 				tmp_priority=jobs[i].getElementsByTagName("priority")[0].firstChild.nodeValue;
 				if(tmp_priority>=max_priority)
 					max_priority=tmp_priority;
 			 }

			var len=jobs.length;
			var j,tmpbuf;
//			var buf=new Array(len);
	             for(i=0;i<jobs.length;i++)
                   	{
				 buf[i]=jobs[i].getElementsByTagName("priority")[0].firstChild.nodeValue;
				 
			 }		
                   //sort buf[] descending
    
    for(i=0;i<len-1;i++)
                   	{
		            for(j=i+1;j<len;j++)
					if(parseInt(buf[j])>parseInt(buf[i]))
						{
							tmpbuf=buf[i];
							buf[i]=buf[j];
							buf[j]=tmpbuf;
						}
			   }
                   
	

				   
			for (i = 0; i < jobs.length; i++)
			{
				var id = jobs[i].getElementsByTagName("id")[0].firstChild.nodeValue;
				var name = jobs[i].getElementsByTagName("name")[0].firstChild.nodeValue;1
				var size = jobs[i].getElementsByTagName("size")[0].firstChild.nodeValue;
				var downloaded = jobs[i].getElementsByTagName("downloaded")[0].firstChild.nodeValue;
				var dwrate = jobs[i].getElementsByTagName("dwrate")[0].firstChild.nodeValue;
				var npeers = jobs[i].getElementsByTagName("npeers")[0].firstChild.nodeValue;
				var percent = jobs[i].getElementsByTagName("percent")[0].firstChild.nodeValue;						 
				var priority=jobs[i].getElementsByTagName("priority")[0].firstChild.nodeValue;	
				var status=jobs[i].getElementsByTagName("status")[0].firstChild.nodeValue;

				//priority=max_priority-priority+1;
				//get the sub ,so priority can be continous~
				j=0;
				while(buf[j++]!=priority)
					;
				priority=j;
                           
			 
				
	

				
                       //staus:active--green;inactive--red;
                         if((status.indexOf("downloading")==0)|(status.indexOf("started")==0)|((status.indexOf("seeding")==0)&&(status.indexOf("seeding/inactive")!=0)))
						 	var status_color="#FFFF00";
						 else 
						 	if((status.indexOf("inactive/stopped")==0)|(status.indexOf("inactive/error")==0))
						 	var status_color="#FF0201";
								else
									if(status.indexOf("inactive/finished")==0)
										status_color="#6699FF";
									 else
									 	if(status.indexOf("stopping")==0)
									 		status_color="#C1FFC1";
										else
										 	status_color="#FFFFFF";
					
				var row = document.createElement("tr");
				row.setAttribute("id",i);
				/* No. */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(i+1);
				cell.appendChild(textNode);
				cell.setAttribute("width", "35");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color = status_color;
				var checkbt = document.createElement("input");
				checkbt.type="checkbox";
				checkbt.setAttribute("name","btcheck");
				checkbt.setAttribute("id",id);
				checkbt.checked = false;
				checkbt.defaultChecked = false;
				checkbt.onclick=new Function ("onCheckClick('" + i +"','" + id +"');");
				cell.appendChild(checkbt);
				row.appendChild(cell);
				
				/* File name */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(name);
				cell.appendChild(textNode);
				cell.setAttribute("width", "182");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color =status_color;
				cell.style.overflow="hidden";
				row.appendChild(cell);
				
				/* Size */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(size);
				cell.appendChild(textNode);
				cell.setAttribute("width", "80");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color = status_color;
				row.appendChild(cell);	

				/* Priority */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(priority);
				cell.appendChild(textNode);
				cell.setAttribute("width", "60");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color = status_color;
				row.appendChild(cell);	
				
				/* Percent */
				var cell = document.createElement("td");
				var placeholder = document.createElement("img");//create img
				placeholder.setAttribute("id","placeholder");
				placeholder.setAttribute("src","image/bar.gif");
				placeholder.setAttribute("width",(parseInt(percent)+1.5)*1.7);
				placeholder.setAttribute("height",18);
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.appendChild(placeholder);
				
				var textNode = document.createTextNode(percent);
				cell.appendChild(textNode);
				cell.setAttribute("width", "233");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color = status_color;
				row.appendChild(cell);	
				
				/* Peers */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(npeers);
				cell.appendChild(textNode);
				cell.setAttribute("width", "53");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color = status_color;
				row.appendChild(cell);	
			
				/* Speed */
				var cell = document.createElement("td");
				var textNode = document.createTextNode(dwrate);
				cell.appendChild(textNode);
				cell.setAttribute("width", "107");
				cell.setAttribute("className", "tt1line");
				cell.setAttribute("class", "tt1line");
				cell.style.color = status_color;
				row.appendChild(cell);	
				
				torrenttbody.appendChild(row);
			}
			document.getElementById("btStart").disabled=true;
			document.getElementById("btStop").disabled=true;
			document.getElementById("btDelete").disabled=true;
			document.getElementById("btSetting").disabled=false;
			document.getElementById("btAddNew").disabled=false;
			document.getElementById("btRefresh").disabled=false;
			/*
			document.getElementById("btSetting").href="WebTorrentSetting.html";
			document.getElementById("btAddNew").href="torrentupload.html";
			disablehref(btStart);
			disablehref(btStop);
			disablehref(btDelete);
			enablehref(btRefresh,updateAllInfo);
			*/
			if (jobs.length > 1)
			{
				document.getElementById("btUp").disabled=false;
				document.getElementById("btDown").disabled=false;
				//enablehref(btUp,increasePrio);
				//enablehref(btDown,decreasePrio);
			}
			else
			{
				document.getElementById("btUp").disabled=true;
				document.getElementById("btDown").disabled=true;
				//disablehref(btUp);
				//disablehref(btDown);
			}
			
			if (highli < 0)
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
			tr_list[highli].style.backgroundColor = "#999999";
			onDetailRefresh();
			return;					
		}
	}
	else
	{
		window.location="./home.html";
		return;		
	}
}

function showTorrentStatus()
{
	
	var url = "/cgi-bin/UniCGI.cgi?id=7";
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
			sleep(2);
			clearPrevTable();
			responseTorrentCommand();
		}
	}
}

/* Refresh Detail Table */
function onDetailRefresh()
{
	var url;
	
	if (highli < 0)
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
		if ((tr_list[i].style.backgroundColor != "#000000")&&(tr_list[i].style.backgroundColor !="black"))
		{
			highli = i;
			var firsttd = tr_list[i].cells[0];
			var checkbt = firsttd.getElementsByTagName("input");
			if ((checkbt[0].type=="checkbox") && (checkbt[0].name=="btcheck"))
			{
				url = "/cgi-bin/UniCGI.cgi?id=7&op=7&opid="+checkbt[0].id;
				showTorrentDetail(url);
				break;
			}
			
		}
	}	
}
/* Start Torrent Job */
function handleStartTorrent()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
		      sleep(2);
			onDetailRefresh();
			updateAllInfo();
		}
	}
}

function startTorrent()
{
	var checkbt = document.getElementsByTagName("input");
	var id = "";
	var totalchecked = 0;

	for (var outi=0; outi < checkbt.length; outi++)
	{
		if ((checkbt[outi].type=="checkbox") && (checkbt[outi].name=="btcheck"))
		{	
			if (checkbt[outi].checked)
			{
				id = id + "&opid" + totalchecked + "=" + checkbt[outi].id;
				totalchecked = totalchecked + 1;
			}
		}
	}
	
	if (id=="")
	{
		return;
	}
	
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=2&opid=0&total="+totalchecked + id;	
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleStartTorrent;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}

/* Stop Torrent Job */
function handleStopTorrent()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			onDetailRefresh();
			updateAllInfo();
			
		}
	}
}

function stopTorrent()
{
	var checkbt = document.getElementsByTagName("input");
	var id = "";
	var totalchecked = 0;

	for (var outi=0; outi < checkbt.length; outi++)
	{
		if ((checkbt[outi].type=="checkbox") && (checkbt[outi].name=="btcheck"))
		{	
			if (checkbt[outi].checked)
			{
				id = id + "&opid" + totalchecked + "=" + checkbt[outi].id;
				totalchecked = totalchecked + 1;
			}
		}
	}
	
	if (id=="")
	{
		return;
	}
	
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=1&opid=0&total="+totalchecked + id;	
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleStopTorrent;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}

/* Delete Torrent File */

function handleDeleteTorrent()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			window.location="./WebTorrentHome.html";
		}
	}
}

function deleteTorrent()
{
	var checkbt = document.getElementsByTagName("input");
	var id = "";
	var totalchecked = 0;

	
	for (var outi=0; outi < checkbt.length; outi++)
	{
		if ((checkbt[outi].type=="checkbox") && (checkbt[outi].name=="btcheck"))
		{	
			if (checkbt[outi].checked)
			{
				id = id + "&opid" + totalchecked + "=" + checkbt[outi].id;
				totalchecked = totalchecked + 1;
			}
		}
	}
	if (id=="")
	{
		return;
	}
	var ret = confirm("Unfinished jobs will be deleted. Proceed?", "Yes", "No");
	if (ret === false)
		return;
	
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=5&opid=0&total="+totalchecked + id;	
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleDeleteTorrent;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}



function deleteTorrentOnly()
{
	var checkbt = document.getElementsByTagName("input");
	var id = "";
	var totalchecked = 0;

	
	for (var outi=0; outi < checkbt.length; outi++)
	{
		if ((checkbt[outi].type=="checkbox") && (checkbt[outi].name=="btcheck"))
		{	
			if (checkbt[outi].checked)
			{
				id = id + "&opid" + totalchecked + "=" + checkbt[outi].id;
				totalchecked = totalchecked + 1;
			}
		}
	}
	if (id=="")
	{
		return;
	}
	var ret = confirm("Only torrents will be deleted. Proceed?", "Yes", "No");
	if (ret === false)
		return;
	
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=4&opid=0&total="+totalchecked + id;	
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleDeleteTorrent;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}



function deleteTorrentAndData()
{
	var checkbt = document.getElementsByTagName("input");
	var id = "";
	var totalchecked = 0;

	
	for (var outi=0; outi < checkbt.length; outi++)
	{
		if ((checkbt[outi].type=="checkbox") && (checkbt[outi].name=="btcheck"))
		{	
			if (checkbt[outi].checked)
			{
				id = id + "&opid" + totalchecked + "=" + checkbt[outi].id;
				totalchecked = totalchecked + 1;
			}
		}
	}
	if (id=="")
	{
		return;
	}
	var ret = confirm("Both torrent and data  will be deleted. Proceed?", "Yes", "No");
	if (ret === false)
		return;
	
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=5&opid=0&total="+totalchecked + id;	
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleDeleteTorrent;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
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
		tr_list[rowid].style.backgroundColor = "#999999";
		highli = rowid;
		
		var firsttd = tr_list[rowid].cells[0];
		var checkbt = firsttd.getElementsByTagName("input");
		if ((checkbt[0].type=="checkbox") && (checkbt[0].name=="btcheck"))
		{
			showTorrentDetail("/cgi-bin/UniCGI.cgi?id=7&op=7&opid="+checkbt[0].id);
		}
	}
}

function updateAllInfo()
{
	var i=0;
	if(torrentInterval == 0)
		torrentInterval = setInterval("updateAllInfo()", 10000);

	if(document.all)
	{
		var torrenttable = document.getElementById("torrenttable").children[0]; 
	}
	else 
	{
		var torrenttable = document.getElementById("torrenttable"); 
	}
	
	if (torrenttable !== null)
	{
		var tr_list = torrenttable.getElementsByTagName('tr');
		for (i = 0; i < tr_list.length; i++)
		{
			if ((tr_list[i].style.backgroundColor != "#000000")&&(tr_list[i].style.backgroundColor !="black"))
			{
				highli = i;
				break;
			}
		}
	}
	showTorrentStatus();
}

/* increase priority */

function handleIncPrio()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			showTorrentStatus();
			//torrentInterval = setInterval("updateAllInfo()", 10000);
		}
	}
}

function increasePrio()
{
	var id1=0;
	var id2=0;
	var found = 0;
	var i=0;
	if(document.all)
	{
		var torrenttable = document.getElementById("torrenttable").children[0]; 
	}
	else 
	{
		var torrenttable = document.getElementById("torrenttable"); 
	}
	
	if (torrenttable !== null)
	{
		var tr_list = torrenttable.getElementsByTagName('tr');
		for (i = 0; i < tr_list.length; i++)
		{
			if ((tr_list[i].style.backgroundColor != "#000000")&&(tr_list[i].style.backgroundColor !="black"))
			{
				if (i < 1)
				{
					return;
				}
				var firsttd = tr_list[i].cells[0];
				var prevtd = tr_list[i -1].cells[0];
				var checkbt = firsttd.getElementsByTagName("input");
				var prevcheckbt = prevtd.getElementsByTagName("input");
				if ((checkbt[0].type=="checkbox") && (checkbt[0].name=="btcheck") 
					&&(prevcheckbt[0].type == "checkbox") && (prevcheckbt[0].name=="btcheck"))
				{				
					id2 = checkbt[0].id;
					id1 = prevcheckbt[0].id;
					highli = i-1;					
					found = 1;
					break;
				}
				else
				{
					return;
				}
			}
		}
	}
	if (found == 1)
	{
		//clearInterval(torrentInterval);
		var url = "/cgi-bin/UniCGI.cgi?id=7&op=15&opid=0&id1=" + id1 + "&id2=" + id2;
		createXMLHttpRequest();
		xmlHttp.onreadystatechange = handleIncPrio;
		xmlHttp.open("GET", url, true);
		xmlHttp.setRequestHeader("If-Modified-Since", "0");
		xmlHttp.send(null);		
	}
}

/* decrease priority */
function handleDecPrio()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			showTorrentStatus();
			//torrentInterval = setInterval("updateAllInfo()", 10000);
		}
	}
}

function decreasePrio()
{
	var id1=0;
	var id2=0;
	var found = 0;
	var i=0;
	if(document.all)
	{
		var torrenttable = document.getElementById("torrenttable").children[0]; 
	}
	else 
	{
		var torrenttable = document.getElementById("torrenttable"); 
	}
	
	if (torrenttable !== null)
	{
		var tr_list = torrenttable.getElementsByTagName('tr');
		for (i = 0; i < tr_list.length; i++)
		{
			if ((tr_list[i].style.backgroundColor != "#000000")&&(tr_list[i].style.backgroundColor !="black"))
			{
				if (i >= (tr_list.length - 1))
				{
					return;
				}
				var firsttd = tr_list[i].cells[0];
				var prevtd = tr_list[i + 1].cells[0];
				var checkbt = firsttd.getElementsByTagName("input");
				var prevcheckbt = prevtd.getElementsByTagName("input");
				if ((checkbt[0].type=="checkbox") && (checkbt[0].name=="btcheck") 
					&&(prevcheckbt[0].type == "checkbox") && (prevcheckbt[0].name=="btcheck"))
				{				
					id1 = checkbt[0].id;
					id2 = prevcheckbt[0].id;
					highli = i+1;
					found = 1;
					break;
				}
				else
				{
					return;
				}
			}
		}
	}
	if (found == 1)
	{
		//clearInterval(torrentInterval);
		var url = "/cgi-bin/UniCGI.cgi?id=7&op=15&opid=0&id1=" + id1 + "&id2=" + id2;
		createXMLHttpRequest();
		xmlHttp.onreadystatechange = handleDecPrio;
		xmlHttp.open("GET", url, true);
		xmlHttp.setRequestHeader("If-Modified-Since", "0");
		xmlHttp.send(null);		
	}	
}


//add by hongjian_shen, to make the delay time enough ,in order not to show the crossed states
function sleep(seconds)
{
 var d1 = new Date();
 var t1 = d1.getTime();
 for (;;)
 {
   var d2 = new Date();
   var t2 = d2.getTime();
   if (t2-t1 > seconds*1000)
   {
      break;
   }
 }
}

