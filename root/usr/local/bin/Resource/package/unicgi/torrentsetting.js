var xmlHttp;
var flag=0;
var testword="Current Partition ERR   ,   Select  Another";

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

function responseTorrentSetting()
{
	var xmlDoc = xmlHttp.responseXML;
	var operation = xmlDoc.getElementsByTagName("operation").item(0);
	var command = operation.getElementsByTagName("command").item(0);
	var commandVal = command.firstChild.nodeValue;
	var ret = operation.getElementsByTagName("return");
	var retVal = ret[0].firstChild.nodeValue;
	
	if (retVal != "OK")
	{
		return;
	}
	var daemon = xmlDoc.getElementsByTagName("daemon")[0];
//	var storage = xmlDoc.getElementsByTagName("storage")[0];
//	var currstorage = xmlDoc.getElementsByTagName("currstorage")[0];
	
	var uprate = daemon.getElementsByTagName("upload");	
	var dwrate = daemon.getElementsByTagName("download");	
	var maxseedtime = daemon.getElementsByTagName("maxseedtime");
	var maxactivetr = daemon.getElementsByTagName("maxactivetr");
	var maxinactivetm = daemon.getElementsByTagName("maxinactivetm");
	var autodel= daemon.getElementsByTagName("autodelfinish");
	
	var uprateVal = uprate[0].firstChild.nodeValue;
	var dwrateVal = dwrate[0].firstChild.nodeValue;
	var maxseedtimeVal = maxseedtime[0].firstChild.nodeValue;
	var maxactivetrVal = maxactivetr[0].firstChild.nodeValue;
	var maxinactivetmVal = maxinactivetm[0].firstChild.nodeValue;
	var autodelValue= autodel[0].firstChild.nodeValue;
		
//	var currpartition = currstorage.getElementsByTagName("name")[0].firstChild.nodeValue;
//	var partition = storage.getElementsByTagName("partition");	
//	var storageselect = document.getElementById("storagelist");
	//var selectindex = 0;

	
	
	var input_maxdwrate = document.getElementById("maxdwrate");
	input_maxdwrate.value=dwrateVal;
	var input_maxuprate = document.getElementById("maxuprate");
	input_maxuprate.value = uprateVal;
	var input_timetostop = document.getElementById("timetostop");
	input_timetostop.value = maxinactivetmVal;
	var input_timetonext = document.getElementById("timetonext");
	input_timetonext.value = maxseedtimeVal;
	var input_maxtask = document.getElementById("maxtask");
	input_maxtask.value = maxactivetrVal;
	var input_autodel = document.getElementById("autodelfinish");
	input_autodel.value = autodelValue;

}

function handleTorrentSetting()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			responseTorrentSetting();
		}
	}
}

function showTorrentSetting()
{
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=13&opid=0";
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleTorrentSetting;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}

/* Save settings */
function responseSaveSetting()
{
	var xmlDoc = xmlHttp.responseXML;
	var operation = xmlDoc.getElementsByTagName("operation").item(0);
	var command = operation.getElementsByTagName("command").item(0);
	var commandVal = command.firstChild.nodeValue;
	var ret = operation.getElementsByTagName("return");

	var retString = operation.getElementsByTagName("string");
	window.location="./WebTorrentHome.html";
}

function handleSaveSetting()
{
	if(xmlHttp.readyState == 4)
	{
		if(xmlHttp.status == 200)
		{
			responseSaveSetting();
		}
	}
}

function onSettingsSave()
{


	  
//	var optindex = document.getElementById("storagelist").options.selectedIndex;


//	   var input_storage = document.getElementById("storagelist").options[optindex].text;	 

	 //  alert(flag);
	//   alert(input_storage);
	//   alert(input_storage.length);
	//   alert(testword.length);
//	  if(input_storage.length==38)       // 38 is the length of "Current Partition ERR   ,   Select  Another",but why not 43??
//		 {
//			alert("Curr Partition ERR , PLEASE Select Valid Partitions");
//			return;
//	 	}
	
//	if (optindex >= 0)
//	{
//		var input_storage = document.getElementById("storagelist").options[optindex].text;
//	}
//	else
//	{
//		var input_storage = "";
//	} 

	var input_maxdwrate = document.getElementById("maxdwrate").value;
	var input_maxuprate = document.getElementById("maxuprate").value;
	var input_timetostop = document.getElementById("timetostop").value;
	var input_timetonext = document.getElementById("timetonext").value;
	var input_maxtask = document.getElementById("maxtask").value;
	var input_autodel= document.getElementById("autodelfinish").value;

//	var url = "/cgi-bin/UniCGI.cgi?id=7&op=14&opid=0&up=" + input_maxuprate + "&down=" + input_maxdwrate + "&storage=" + input_storage + "&seed=" + input_timetonext + "&idmin=" + input_timetostop + "&nact=" + input_maxtask + "&autodel=" + input_autodel;
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=14&opid=0&up=" + input_maxuprate + "&down=" + input_maxdwrate +"&seed=" + input_timetonext + "&idmin=" + input_timetostop + "&nact=" + input_maxtask + "&autodel=" + input_autodel;
	createXMLHttpRequest();
	xmlHttp.onreadystatechange = handleSaveSetting;
	xmlHttp.open("GET", url, true);
	xmlHttp.setRequestHeader("If-Modified-Since", "0");
	xmlHttp.send(null);
}

/* Set default */
function onSettingsDefault()
{
//	var input_storage = document.getElementById("storagelist");
	var input_maxdwrate = document.getElementById("maxdwrate");
	var input_maxuprate = document.getElementById("maxuprate");
	var input_timetostop = document.getElementById("timetostop");
	var input_timetonext = document.getElementById("timetonext");
	var input_maxtask = document.getElementById("maxtask");	
	var input_autodel= document.getElementById("autodelfinish");	
	
//	input_maxdwrate.value = "-1";
	input_maxdwrate.value = "0";
	input_maxuprate.value = "20";
	input_timetostop.value = "1";
	input_timetonext.value = "24";
	input_maxtask.value = "4";
	input_autodel.value="0";
}
