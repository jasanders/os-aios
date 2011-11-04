var xmlHttp;
var partition_using=0;
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
	partition_using=0;
	var flag=0;
	
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
	var storage = xmlDoc.getElementsByTagName("storage")[0];
	var currstorage = xmlDoc.getElementsByTagName("currstorage")[0];
	
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
		
	var currpartition = currstorage.getElementsByTagName("name")[0].firstChild.nodeValue;
	var partition = storage.getElementsByTagName("partition");	

	if((partition.length)==0)    // if no one disk exsits! back to home
		{
			alert("No one partition is found , please add at least one disk!");
			window.location="./WebTorrentHome.html";    
		}	


	var storageselect = document.getElementById("storagelist");
	//var selectindex = 0;

		var torrent = xmlDoc.getElementsByTagName("torrent")[0];		

		var total = torrent.getElementsByTagName("total")[0].firstChild.nodeValue;

		if (total == "0")
			{
			   	 partition_using=0;
			}
		else	{
					
			var jobs = torrent.getElementsByTagName("job");
			var i;

			var len=jobs.length;
				   
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


			 		if(status.indexOf("inactive")!=0)
			 			{
						partition_using=1;
						break;
						}

				}
			
			   if(i==jobs.length) 
			   	 partition_using=0;
			}

	if (currpartition!=0)
	{
		for (var i=0; i<partition.length; i++)
		{
			var partname = partition[i].getElementsByTagName("name")[0].firstChild.nodeValue;
			if(partname==currpartition)
				{
				flag=1;
				break;
				}
		
		}
	}
	else
	{
		  // alert("bb");
		     partition_using=0;
	}

	for (var i=0; i<partition.length; i++)
	{
		var partname = partition[i].getElementsByTagName("name")[0].firstChild.nodeValue;
	
		var option = document.createElement("option");
		var text = document.createTextNode(partname);
		
		if (currpartition!=0)
			{

				if(flag==0)       //in part lists,no currpart exist -->set 1st selected
					{
						if(i==0)
								{
							
								option.selected = true;
								
								
								
								}
					}else
						{
						   if(partname==currpartition)
						   	{
								option.selected = true;
						   	}
						}


			}
		else
			{
				if(i==0)
					{
					option.selected = true;
					}
		       }

		option.appendChild(text);
		storageselect.appendChild(option);

	}

		if(partition_using==1)
			{
			storageselect.disabled=true;
			}
  	

   
	onSettingsSave();  //default set one !

	//add by shen
	//if(flag==0)   // means currpatition is not in the storagelist ,maybe disk error
	//	{
       //         var option = document.createElement("option");
       //         var text = document.createTextNode(testword);
	//	   option.selected = true;
		//   flag=1;
	//	   option.appendChild(text);
	//	   storageselect.appendChild(option);	   
	//       }
	
	//storageselect.selectedIndex = selectindex;
	
//	var input_maxdwrate = document.getElementById("maxdwrate");
//	input_maxdwrate.value=dwrateVal;
//	var input_maxuprate = document.getElementById("maxuprate");
//	input_maxuprate.value = uprateVal;
//	var input_timetostop = document.getElementById("timetostop");
//	input_timetostop.value = maxinactivetmVal;
//	var input_timetonext = document.getElementById("timetonext");
//	input_timetonext.value = maxseedtimeVal;
//	var input_maxtask = document.getElementById("maxtask");
//	input_maxtask.value = maxactivetrVal;
//	var input_autodel = document.getElementById("autodelfinish");
//	input_autodel.value = autodelValue;

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
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=17&opid=0";
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
			//responseSaveSetting();
		//	sleep(2);
			//document.form1.submit();
	//	window.location="./WebTorrentHome.html";
		}
	}
}

function onSettingsSave()
{



	var optindex = document.getElementById("storagelist").options.selectedIndex;


	   var input_storage = document.getElementById("storagelist").options[optindex].text;	 

	
	if (optindex >= 0)
	{
		var input_storage = document.getElementById("storagelist").options[optindex].text;
	}
	else
	{
		var input_storage = "";
	} 

	var input_maxdwrate = 0;
	var input_maxuprate = 20;
	var input_timetostop = 1;
	var input_timetonext = 24;
	var input_maxtask = 4;
	var input_autodel= 0;

//	var url = "/cgi-bin/UniCGI.cgi?id=7&op=14&opid=0&up=" + input_maxuprate + "&down=" + input_maxdwrate + "&storage=" + input_storage + "&seed=" + input_timetonext + "&idmin=" + input_timetostop + "&nact=" + input_maxtask + "&autodel=" + input_autodel;
	var url = "/cgi-bin/UniCGI.cgi?id=7&op=16&opid=0&storage=" + input_storage+"&partusing="+partition_using;
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
