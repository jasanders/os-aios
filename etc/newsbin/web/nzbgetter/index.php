<?php
/*

 NZBGetter 1.1a - http://sourceforge.net/projects/nzbgetter/

 NZBGetter is a PHP Script for linux based systems to spider NZB index 
 sites for NZB files matching your predefined search patterns. The 
 script downloads matching NZB files and passes them to your Usenet Reader.

 Copyright 2009 Youri Tromp

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

# Do not show notices
error_reporting(E_ALL & ~E_NOTICE);

# Autoloader for on the fly class initialization
function __autoload($class_name) {
    require_once dirname(__FILE__) . '/lib/classes/' . $class_name . '.class.php';
}

# Wrapper if ctype_alpha isn't working
if(!function_exists('ctype_alpha')){
    function ctype_alpha($text){
        return preg_match("/[A-Za-z]/",$text);
    }
}

# Loading some configuration files
$appGeneral = new nzbg_conf("general");
$appConfig  = new nzbg_conf("config");

# Loading framework template
$templateIndex = new nzbg_template("framework");

# Loading menu template
$templateMenu  = new nzbg_template("menu");

# Fill some placeholder in the framework template
$arrIndexVars = array("TITLE" => $appGeneral->title . ' ' . $appGeneral->version,
                      "CSS" => $appGeneral->css,
                      "JQUERY" => $appGeneral->jquery,
                      "COPYRIGHTYEAR" => $appGeneral->copyrightyear,
                      "AUTHOR" => $appGeneral->author,
                      "URL" => $appGeneral->url);

# Add menu to template
$templateIndex->replace("MENU", $templateMenu->contents());

# Init some variables needed for template purposes
$content       = "";
$jquery_depend = "";

# Check GET variable
$action        = "";

if(isset($_GET['a']) && ctype_alpha($_GET['a'])){
    $action = $_GET['a'];
}else{
    $action = "";
}

# Check IP ?
$access_granted = false;
if(file_exists(dirname(__FILE__).'/conf/ip.txt')){
    # Open file
    $fh    = @fopen(dirname(__FILE__).'/conf/ip.txt', 'r');
    $line  = @fgets($fh);
    $arrIP = explode(",",$line);

    # Get client IP
    $ip = getIP();

    foreach($arrIP as $strIP){

        $strIP = trim(str_replace("*","",$strIP));
        if(substr($ip, 0, strlen($strIP)) == $strIP){
            $access_granted = true;
        }
    }
}else{
    $access_granted = true;
}

if(!$access_granted){
    $templateNoAccess = new nzbg_template("noaccess");
    $content = $templateNoAccess->contents();
}elseif(($appGeneral->settingsapplied == 0) and ($action != "settings")){
    header("Location: ?a=settings");
}else{

    # Decide what template to load depending on link value
    switch($action){

        case "settings":
            # Load settings template
            $templateSettings = new nzbg_template("settings");

            # Replace configuration settings in form
            $arrSettingsVars = array("WGET_FOLDER"      => $appConfig->wgetpath,
                                     "NZB_FOLDER"       => $appConfig->nzbfolder,
                                     "RSS_TVNZB"        => $appConfig->tvnzbfeed,
                                     "RSS_TVNZBHD"      => $appConfig->tvnzbhd,
                                     "RSS_TVNZBSD"      => $appConfig->tvnzbsd,
                                     "NZBINDEX_STR"     => $appConfig->nzbindexfeed,
                                     "NZBINDEX_DAYS"    => $appConfig->nzbindexdays,
                                     "NZBINDEX_RESULTS" => $appConfig->nzbindexresults,
                                     "LOGFILE_NAME"     => $appConfig->logfilename,
                                     "MAXLOGLINES"      => $appConfig->maxloglines,
                                     "STR_TWITUSER"     => $appConfig->twitteruser,
                                     "STR_TWITPASS"     => substr(base64_decode($appConfig->twitterpass),13),
                                     "STR_TWITMSG"      => $appConfig->twittermessage);

            # Decide what dropdown value to be selected for twitter support
            if($appConfig->twitterenabled == "yes"){$arrSettingsVars["TWITTER_ON"] = " selected";$arrSettingsVars["TWITTER_OFF"] = "";}else{$arrSettingsVars["TWITTER_ON"] = "";$arrSettingsVars["TWITTER_OFF"] = " selected";}

            $templateSettings->replace_array($arrSettingsVars);

            # Add to contents
            $content = $templateSettings->contents();

            # This page has some page dependant jquery functionality
            $templateJQ  = new nzbg_template("jquery.settings");
            $jquery_depend = $templateJQ->contents();

            break;
        case "nzbd":
            # First lets check if the delete parameter is found in the url
            if(isset($_GET['d']) and is_numeric($_GET['d'])){

                # Load remove from download list template
                $templateRemoveDownload = new nzbg_template("download.remove");

                # Get entry ID
                $intEntryID = $_GET['d'];

                # Instantiate downloadlist object
                $objDownload = new nzbg_conf("download");

                # Fetch all items to array
                $arrDownloadList = $objDownload->get_xml_as_array();

                # Instantiate the Log object
                $objNZBLog = new nzbg_log($appConfig);

                # Extra check if the item to delete is correct
                if($_GET['t'] == $arrDownloadList[$intEntryID]['title']){

                    $objDownload->delete_download($intEntryID);
                    $arrPlaceholders = array('ITEM' => $arrDownloadList[$intEntryID]['title'],
                                             'FONT_COLOR' => 'black',
                                             'COLOR' => 'green');
                    $objNZBLog->writeLine("Removed entry \"".$arrDownloadList[$intEntryID]['title']."\" from the download list.");
                }else{

                    $arrPlaceholders = array('ITEM' => 'An error occured! Please try again.',
                                             'FONT_COLOR' => 'red',
                                             'COLOR' => 'red');
                    $objNZBLog->writeLine("Removed entry \"".$arrDownloadList[$intEntryID]['title']."\" from the download list failed.");
                }

                # Replace placeholders
                $templateRemoveDownload->replace_array($arrPlaceholders);

                # Add to contents
                $content = $templateRemoveDownload->contents();
            }elseif(isset($_GET['e']) and is_numeric($_GET['e'])){

                # Get entry ID
                $intEntryID = $_GET['e'];

                # Instantiate downloadlist object
                $objDownload = new nzbg_conf("download");

                # Fetch all items to array
                $arrDownloadList = $objDownload->get_xml_as_array();
                
                switch($arrDownloadList[$intEntryID]['type']){
	                  case "tvnzb":

                        # Load edit template TVNZB
	                      $templateEdit = new nzbg_template("download.edit.tvnzb");

                        $arrPlaceholders = array('ID' => $intEntryID,
                                                 'ENTRYTITLE' => $arrDownloadList[$intEntryID]['title'],
                                                 'ENTRYPATTERN' => $arrDownloadList[$intEntryID]['findstring']);

                        # Which quality selected?
                        if($arrDownloadList[$intEntryID]['quality'] == "HD"){
                            $selected_hd = " selected";
                            $selected_sd = "";
                        }else{
                            $selected_sd = " selected";
                            $selected_hd = "";
                        }

                        # Which methode selected?
                        if($arrDownloadList[$intEntryID]['downloadtype'] == "queue"){
                            $selected_qu = " selected";
                            $selected_au = "";
                        }else{
                            $selected_au = " selected";
                            $selected_qu = "";
                        }

                        if(isset($arrDownloadList[$intEntryID]['fixednzbname'])){
                            $arrPlaceholders['FIXEDNZBNAME'] = str_replace(".nzb","",$arrDownloadList[$intEntryID]['fixednzbname']);
                        }else{
                            $arrPlaceholders['FIXEDNZBNAME'] = "";
                        }

                        # Fill in placeholders selected values
                        $arrPlaceholders['QUALITY_HD'] = $selected_hd;
                        $arrPlaceholders['QUALITY_SD'] = $selected_sd;
                        $arrPlaceholders['DL_AUTO']    = $selected_au;
                        $arrPlaceholders['DL_QUEUE']   = $selected_qu;

                        $templateEdit->replace_array($arrPlaceholders);

	                      break;
	                  case "nzbindex":

	                      # Load edit template TVNZB
	                      $templateEdit = new nzbg_template("download.edit.nzbindex");

	                      $arrPlaceholders = array('ID' => $intEntryID,
                                                 'ENTRYTITLE' => $arrDownloadList[$intEntryID]['title'],
                                                 'ENTRYPATTERN' => $arrDownloadList[$intEntryID]['findstring'],
                                                 'ENTRYEXCLUDE' => $arrDownloadList[$intEntryID]['excludekeywords'],
                                                 'ENTRYMINSIZE' => $arrDownloadList[$intEntryID]['minsize'],
                                                 'ENTRYMAXSIZE' => $arrDownloadList[$intEntryID]['maxsize'],
                                                 'ENTRYPOSTER' => $arrDownloadList[$intEntryID]['poster']);

                        # Which methode selected?
                        if($arrDownloadList[$intEntryID]['downloadtype'] == "queue"){
                            $selected_qu = " selected";
                            $selected_au = "";
                        }else{
                            $selected_au = " selected";
                            $selected_qu = "";
                        }

                        if(isset($arrDownloadList[$intEntryID]['fixednzbname'])){
                            $arrPlaceholders['FIXEDNZBNAME'] = str_replace(".nzb","",$arrDownloadList[$intEntryID]['fixednzbname']);
                        }else{
                            $arrPlaceholders['FIXEDNZBNAME'] = "";
                        }

                        # Fill in placeholders selected values
                        $arrPlaceholders['DL_AUTO']    = $selected_au;
                        $arrPlaceholders['DL_QUEUE']   = $selected_qu;

                        $templateEdit->replace_array($arrPlaceholders);

	                      break;
                }

                # Add to contents
                $content = $templateEdit->contents();

                # This page has some page dependant jquery functionality
                $templateJQ = new nzbg_template("jquery.download.edit");
                $jquery_depend = $templateJQ->contents();
            }else{

                # Load download list template
                $templateDownload = new nzbg_template("download");

                # Add to contents
                $content = $templateDownload->contents();

                # This page has some page dependant jquery functionality
                $templateJQ = new nzbg_template("jquery.downloads");
                $jquery_depend = $templateJQ->contents();
            }

            break;
        case "nzbq":
            # First lets check if the download parameter is found in the url
            if(isset($_GET['dl']) and is_numeric($_GET['dl'])){

                # Load move from queue to incoming template
                $templateQueueProcess = new nzbg_template("queue.process");

                # Get entry ID
                $intEntryID = $_GET['dl'];

                # Instantiate queuelist object
                $objQueue = new nzbg_conf("queue");

                # Fetch all items to array
                $arrQueueList = $objQueue->get_xml_as_array();

                # Instantiate the Log object
                $objNZBLog = new nzbg_log($appConfig);

                # Extra check if the item to process is correct
                if($_GET['t'] == $arrQueueList[$intEntryID]['matchtitle']){

                  # Move file to another directory using http://php.net/rename
	                if(@rename(dirname(__FILE__).'/__exec__/queue/'.$arrQueueList[$intEntryID]['nzb'],$appConfig->nzbfolder.$arrQueueList[$intEntryID]['nzb'])){
                        $objQueue->delete_download($intEntryID);

                        $arrPlaceholders = array('ITEM' => $arrQueueList[$intEntryID]['nzb'],
                                                 'FONT_COLOR' => 'black',
                                                 'COLOR' => 'green');
                        $objNZBLog->writeLine("Processed \"".$arrQueueList[$intEntryID]['nzb']."\" to incoming NZB directory.");

                        # Tweet ?
                        if($appConfig->twitterenabled == "yes"){
                            if(function_exists('curl_init')){
                                # Instantiate a Twitter object
                                $objTwitter = new twitter($appConfig->twitteruser, substr(base64_decode($appConfig->twitterpass),13));
                                $strTweet   = $appConfig->twittermessage;

                                if (strpos($strTweet, '%nzbgetter') !== false){
                                    $objSettings = new nzbg_conf("general");
                                    $strTweet = str_replace('%nzbgetter', $objSettings->title.' '.$objSettings->version, $strTweet);
                                }
                                $strTweet = str_replace('%download', $arrQueueList[$intEntryID]['matchtitle'], $strTweet);
                                $objTwitter->updateStatus($strTweet);
                                $objNZBLog->writeLine("Tweeting download ".$arrQueueList[$intEntryID]['matchtitle']);
                            }
                        }
	                }else{
                        $arrPlaceholders = array('ITEM' => 'An error occured! Please try again.',
                                                 'FONT_COLOR' => 'red',
                                                 'COLOR' => 'red');
                        $objNZBLog->writeLine("Failed processing \"".$arrQueueList[$intEntryID]['nzb']."\" to incoming NZB directory.");
	                }

                }else{
                    $arrPlaceholders = array('ITEM' => 'An error occured! Please try again.',
                                             'FONT_COLOR' => 'red',
                                             'COLOR' => 'red');
                    $objNZBLog->writeLine("Failed processing \"".$arrQueueList[$intEntryID]['nzb']."\" to incoming NZB directory.");
                }

                # Replace placeholders
                $templateQueueProcess->replace_array($arrPlaceholders);

                # Add to contents
                $content = $templateQueueProcess->contents();
            }elseif(isset($_GET['d']) and is_numeric($_GET['d'])){

                # Load remove from queue list template
                $templateQueueRemove = new nzbg_template("queue.remove");

                # Get entry ID
                $intEntryID = $_GET['d'];

                # Instantiate queue object
                $objQueue = new nzbg_conf("queue");

                # Fetch all items to array
                $arrQueueList = $objQueue->get_xml_as_array();

                # Instantiate the Log object
                $objNZBLog = new nzbg_log($appConfig);

                # Extra check if the item to delete is correct
                if($_GET['t'] == $arrQueueList[$intEntryID]['matchtitle']){

                    $objQueue->delete_download($intEntryID);
                    $arrPlaceholders = array('ITEM' => $arrQueueList[$intEntryID]['nzb'],
                                             'FONT_COLOR' => 'black',
                                             'COLOR' => 'green');
                    $objNZBLog->writeLine("Removed entry \"".$arrQueueList[$intEntryID]['nzb']."\" from the NZB verification queue.");
                }else{

                    $arrPlaceholders = array('ITEM' => 'An error occured! Please try again.',
                                             'FONT_COLOR' => 'red',
                                             'COLOR' => 'red');
                    $objNZBLog->writeLine("Removed entry \"".$arrQueueList[$intEntryID]['nzb']."\" from the NZB verification queue failed.");
                }

                # Replace placeholders
                $templateQueueRemove->replace_array($arrPlaceholders);

                # Add to contents
                $content = $templateQueueRemove->contents();
            }elseif(isset($_GET['r']) and is_numeric($_GET['r'])){

                # Load remove from queue list template
                $templateQueueRename = new nzbg_template("queue.rename");

                # Get entry ID
                $intEntryID = $_GET['r'];

                # Instantiate queue object
                $objQueue = new nzbg_conf("queue");

                # Fetch all items to array
                $arrQueueList = $objQueue->get_xml_as_array();

                # NZB filename
                $nzbfilename = str_replace(".nzb","",$arrQueueList[$intEntryID]['nzb']);
                $templateQueueRename->replace("ID", $intEntryID);
                $templateQueueRename->replace("NZB", $nzbfilename);

                # Add to contents
                $content = $templateQueueRename->contents();

                # This page has some page dependant jquery functionality
                $templateJQ = new nzbg_template("jquery.queue.rename");
                $jquery_depend = $templateJQ->contents();

            }else{
                # Load dowload list template
                $templateDownloadQueue = new nzbg_template("queue");

                # Add to contents
                $content = $templateDownloadQueue->contents();

                # This page has some page dependant jquery functionality
                $templateJQ = new nzbg_template("jquery.queue");
                $jquery_depend = $templateJQ->contents();
            }

            break;
        case "cron":
            # load cron template
            $templateCron = new nzbg_template("cron");

            $content = $templateCron->contents();

            # This page has some page dependant jquery functionality
            $templateJQ = new nzbg_template("jquery.cron");
            $jquery_depend = $templateJQ->contents();

            break;
        case "log":
            # Load log template
            $templateLog = new nzbg_template("log");
            $content = $templateLog->contents();

            # This page has some page dependant jquery functionality
            $templateJQ  = new nzbg_template("jquery.log");
            $jquery_depend = $templateJQ->contents();

            break;
        case "run":
            # Load log template
            $templateRun = new nzbg_template("run");
            $content = $templateRun->contents();

            # This page has some page dependant jquery functionality
            $templateJQ  = new nzbg_template("jquery.run");
            $jquery_depend = $templateJQ->contents();

            break;
        default:
            # No action, so it must be main
            $templateMain = new nzbg_template("main");

            # Check queue
            $objQueue = new nzbg_conf("queue");

            $intQueueRecords = $objQueue->count_records();

            if($intQueueRecords > 0){
                $templateMainQueueMsg = new nzbg_template("main.queue.message");
                $templateMainQueueMsg->replace("NUMBER", $intQueueRecords);
                $templateMain->replace("QUEUE_MESSAGE", $templateMainQueueMsg->contents());
            }else{
                $templateMain->replace("QUEUE_MESSAGE", "");
            }

            if($appGeneral->ipmessageread == 0){
                $templateIPMessage = new nzbg_template("main.ip.message");
                $templateIPMessage->replace("CURRENTIP", getip());
                $templateMain->replace("IP_MESSAGE", $templateIPMessage->contents());

                # This page has some page dependant jquery functionality
                $templateJQ  = new nzbg_template("jquery.main.ip.message");
                $jquery_depend = $templateJQ->contents();
            }else{
                $templateMain->replace("IP_MESSAGE","");
            }

            $content = $templateMain->contents();
            break;
    }
}

# We can add the correct page to the content placeholder
$templateIndex->replace("CONTENT", $content);

# Add some needed jquery
$arrIndexVars["JQUERY_PAGE_DEPEND"] = $jquery_depend;

# Replace vars on index page
$templateIndex->replace_array($arrIndexVars);

# Finaly! We can render the page!
$templateIndex->render();

# Function for determing the clients IP
function getIP()
{
    if (!empty($_SERVER['HTTP_CLIENT_IP']))
        $ip=$_SERVER['HTTP_CLIENT_IP'];
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ip=$_SERVER['HTTP_X_FORWARDED_FOR'];
    else
        $ip=$_SERVER['REMOTE_ADDR'];

    return $ip;
}
?>