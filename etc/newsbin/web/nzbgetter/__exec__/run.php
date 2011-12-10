<?php
/*

 NZBGetter 1.1a - http://sourceforge.net/projects/nzbgetter/

 NZBGetter is a PHP Script for linux based systems to spider NZB index 
 sites for NZB files matching your predefined search patterns. The 
 script downloads matching NZB files and passes them to your Usenet Reader.

 Copyright 2009 Youri Tromp

 This file is part of NZBGetter.

 NZBGetter is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 NZBGetter is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with NZBGetter.  If not, see <http://www.gnu.org/licenses/>.

*/

error_reporting(E_ALL & ~E_NOTICE);

# Check if either manual or cron mode
$run_mode = (isset($_GET['mode']) and $_GET['mode'] == "m") ? true : false;

# Autoloader for on the fly class initialization
function __autoload($class_name) {

    global $run_mode;

    if($run_mode)
        require_once '../lib/classes/' . $class_name . '.class.php';
    else
        require_once dirname(__FILE__).'/../lib/classes/' . $class_name . '.class.php';
}

# Instantiate config object to get some data
$appConfig = new nzbg_conf("config");

# Instantiate the log object for logging purposes
$objNZBLog = new nzbg_log($appConfig);

# Logging start event
$_msg = "Checking for new NZB files";
if($run_mode){ $_msg.=" (manual)";}else{$_msg.=" (scheduled)";};
$objNZBLog->writeLine($_msg);
if($run_mode) $run_mode_result = $_msg."<br />";

# Twitter settings
$twitter_enabled = false;

# Check cURL support
$curl_enabled = function_exists('curl_init') ? true : false;

# The Twitter class needs the cURL library
if($appConfig->twitterenabled == "yes"){
    if($curl_enabled){

        # Instantiate a Twitter object
        $objTwitter = new twitter($appConfig->twitteruser, substr(base64_decode($appConfig->twitterpass),13));
        $strTweet   = $appConfig->twittermessage;

        if (strpos($strTweet, '%nzbgetter') !== false){
            $objSettings = new nzbg_conf("general");
            $strTweet = str_replace('%nzbgetter', $objSettings->title.' '.$objSettings->version, $strTweet);
        }

        $twitter_enabled = true;
    }else{
        $_msg = "PHP cURL is not enabled, so no tweets are send!";
        $objNZBLog->writeLine($_msg);
        if($run_mode) $run_mode_result = $_msg."<br />";
    }
}

# Instantiate download list object and retreive download list as an array
$objDownload = new nzbg_conf("download");
$arrDownloadList = $objDownload->get_xml_as_array();

# Instantiate queue list object
$objQueue = new nzbg_conf("queue");

# Instantiate a rss object to retreive tvnzb feed
$obj_tvnzb = new rss_php;
$obj_tvnzb->load($appConfig->tvnzbfeed);

# There are no problems loading the RSS
if($obj_tvnzb->errorcode == 0){

    # Load the tvnzb feed into an array
    $arrTVNzbs = $obj_tvnzb->getItems(true);

    # Well, let's loop tvnzb
    foreach($arrTVNzbs as $current_nzb){

        $current_key = 0;

        # We need to compare it against our downloadlist
        foreach($arrDownloadList as $downloadentry){

            # Type needs to be tvnzb
            if($downloadentry['type'] == "tvnzb"){

                # Fetch title from feed and get string to compare, all to be lowercase
                $rss_title      = strtolower($current_nzb['title']['value']);
                $find_string    = strtolower($downloadentry['findstring']);

                # Get the quality
                if($downloadentry['quality'] == "HD"){
                    $quality_string = strtolower($appConfig->tvnzbhd);
                }elseif($downloadentry['quality'] == "SD"){
                    $quality_string = strtolower($appConfig->tvnzbsd);
                }

                # Compare title and quality
                if((strpos($rss_title, $find_string) !== false) and (strpos($rss_title, $quality_string) !== false)){

                    # Get filename from feed to create a dummy to avoid multiple downloading
                    $strFileNZB = strtolower($current_nzb['title']['value']);

                    # Dummy file
                    if($run_mode)
                        $dummy = "dummy/".$strFileNZB.".didit";
                    else
                        $dummy = dirname(__FILE__).'/dummy/'.$strFileNZB.'.didit';

                    # Check if there is a dummy file
                    if(!file_exists($dummy)){

                        # Check if NZB needs to be download to either nzb incoming or queue directory
                        if((isset($downloadentry['downloadtype'])) and ($downloadentry['downloadtype'] == "queue")){
                            $nzbFolder = dirname(__FILE__).'/queue/';
                            $isQueue = true;
                        }else{
                            $nzbFolder = $appConfig->nzbfolder;
                            $isQueue = false;
                        }

                        # Save NZB file to the incoming directory, try using curl, otherwise shell_exec wget
                        if($curl_enabled){
                            # Using cURL (preferred over the wget shell_exec method)
                            $objCurl = new nzbg_curl_download();
                            $objCurl->setFrom( $current_nzb['enclosure']['properties']['url'] );
                            $objCurl->setTo( $nzbFolder.$strFileNZB . '.nzb' );
                            $objCurl->download();
                            unset($objCurl);
                        }else{
                            @shell_exec($appConfig->wgetpath.' -O '.$nzbFolder.$strFileNZB.'.nzb '.$current_nzb['enclosure']['properties']['url']);
                        }

                        # Check if filesize matched, otherwise it's not good
                        $nzb_valid = (@simplexml_load_string(@file_get_contents($nzbFolder.$strFileNZB.'.nzb'))) ? true : false;

                        if($nzb_valid){

	                          if($isQueue){
                                # Add to queue
                                $arrQueue = array('matchtitle' => $downloadentry['title'], 'nzb' => $strFileNZB.'.nzb', 'datefound' => date("d-m-o G:i:s"));
                                $objQueue->add_download($arrQueue);
 	                          }

 	                          # Filename needs to be a fixed one?
 	                          if((!$isQueue) and (isset($downloadentry['fixednzbname'])) and ($downloadentry['fixednzbname'] != '')){
                                $strNZBRenamed = $downloadentry['fixednzbname'];
                                @rename($nzbFolder.$strFileNZB.'.nzb', $nzbFolder.$strNZBRenamed);
 	                          }

                            # Write the dummy file
                            @touch($dummy);

                            # Tweet ?
                            if(($twitter_enabled == true) and ($isQueue == false)){

                                $strTweetFinal = str_replace('%download', $current_nzb['description']['value'], $strTweet);
                                $objTwitter->updateStatus($strTweetFinal);

                                # Logging tweet event
                                $_msg = "Tweeting download ".$current_nzb['description']['value'];
                                $objNZBLog->writeLine($_msg);

                                if($run_mode) $run_mode_result .= $_msg."<br />";
                            }

                            # Download succeeded, wegschrijven succesvolle hit
                            $objDownload->set_hit($current_key);

                            # Write log entry
                            $_msg = "Found NZB file for ".$current_nzb['description']['value']." on TVnzb";
                            if($isQueue) $_msg.=" (add to verification queue)";
                            $objNZBLog->writeLine($_msg);
                            if($run_mode) $run_mode_result .= $_msg."<br />";
                        }else{
                            # Delete file because NZB is invalid
                            unlink($nzbFolder.$strFileNZB.'.nzb');

                            # Write log entry
                            $_msg = "NZB invalid, file deleted!";
                            $objNZBLog->writeLine($_msg);
                            if($run_mode) $run_mode_result .= $_msg."<br />";
                        }
                    }
                }
            }
            $current_key++;
        }
    }
}else{
    # An error occured reading FEED
    $_msg = "Could not load TVNZB feed: ".$appConfig->tvnzbfeed;
    $objNZBLog->writeLine($_msg);
    if($run_mode) $run_mode_result .= $_msg."<br />";
}

# Now we can check nzbindex
$current_key = 0;

# Again we loop our download list
foreach($arrDownloadList as $downloadentry){

    # Type needs to be nzbindex
    if($downloadentry['type'] == "nzbindex"){

        # Get nzbindex feed URL from config
        $strNZBIndexFeed = $appConfig->nzbindexfeed;

        # Replace placeholders in feed URL to get final feed URL to check
        $arrPlaceHolders = array('%q', '%a', '%s', '%m');
        $arrReplacements = array(str_replace(" ","+",strtolower($downloadentry['findstring'])), $appConfig->nzbindexdays,
                                 $downloadentry['minsize'], $appConfig->nzbindexresults);

        $strNZBIndexFeed = str_replace($arrPlaceHolders, $arrReplacements, $strNZBIndexFeed);

        # We need to transform the ampsersand entities for url validity
        $strNZBIndexFeed = str_replace("&amp;", "&", $strNZBIndexFeed);

        # Optional maximum size in megabytes
        if(isset($downloadentry['maxsize'])){
            $strNZBIndexFeed .= "&maxsize=".$downloadentry['maxsize'];
        }

        # Optional postername
        if(isset($downloadentry['poster'])){
            $strNZBIndexFeed .= "&poster=".str_replace(" ","+",(strip_tags($downloadentry['poster'])));
        }

        # Intantiate rss object with the custom build feed url
        $objNZBIndexFeed = new rss_php;

        $objNZBIndexFeed->load($strNZBIndexFeed);

        # There are no problems loading the RSS
        if($objNZBIndexFeed->errorcode == 0){

            # load the nzbindex feed into an array
            $arrNZBIndexNodes = $objNZBIndexFeed->getItems(true);

            # Loop over the results
            foreach($arrNZBIndexNodes as $arrNZBIndexNode){

                # Get filename from feed to create a dummy to avoid multiple downloading
                $strFileNZB = strtolower(substr(strrchr($arrNZBIndexNode['enclosure']['properties']['url'], '/'),1));

                # Now we have a match, but is exclusion needed because of some keywords?
                $exclude = false;

                if(isset($downloadentry['excludekeywords'])){
                    $arrExclude = explode(",",$downloadentry['excludekeywords']);

                    # Check for every value
                    foreach($arrExclude as $v){
                        if((stripos($strFileNZB, $v) !== false) and ($exclude == false)){
                            $exclude = true;
                            $_msg = "Skipping download ".$downloadentry['title']." because keyword ".$v." found";
                            $objNZBLog->writeLine($_msg);
                            if($run_mode) $run_mode_result .= $_msg."<br />";
                        }
                    }
                }

                # No matching exclusion terms so we can download! 
                if($exclude == false){

                    # Dummy file
                    if($run_mode)
                        $dummy = "dummy/".$strFileNZB.".didit";
                    else
                        $dummy = dirname(__FILE__).'/dummy/'.$strFileNZB.'.didit';

                    # Check if there is a dummy file
                    if(!file_exists($dummy)){

	                      # Check if NZB needs to be download to either nzb incoming or queue directory
                        if((isset($downloadentry['downloadtype'])) and ($downloadentry['downloadtype'] == "queue")){
                            $nzbFolder = dirname(__FILE__).'/queue/';
                            $isQueue = true;
                        }else{
                            $nzbFolder = $appConfig->nzbfolder;
                            $isQueue = false;
                        }

                        # Save NZB file to the incoming directory, try using curl, otherwise shell_exec wget
                        if($curl_enabled){
                            # Using cURL (preferred over the wget shell_exec method)
                            $objCurl = new nzbg_curl_download();
                            $objCurl->setFrom( $arrNZBIndexNode['enclosure']['properties']['url'] );
                            $objCurl->setTo( $nzbFolder . $strFileNZB );
                            $objCurl->download();
                            unset($objCurl);
                        }else{
                            @shell_exec($appConfig->wgetpath.' -O '.$nzbFolder.$strFileNZB.' '.$arrNZBIndexNode['enclosure']['properties']['url']);
                        }

                        # Check if filesize matched, otherwise it's not good
                        $nzb_valid = (@simplexml_load_string(@file_get_contents($nzbFolder.$strFileNZB))) ? true : false;

                        if($nzb_valid){

	                          if($isQueue){
                                # Add to queue
                                $arrQueue = array('matchtitle' => $downloadentry['title'], 'nzb' => $strFileNZB, 'datefound' => date("d-m-o G:i:s"));
                                $objQueue->add_download($arrQueue);
	                          }

	                          # Filename needs to be a fixed one?
 	                          if((!$isQueue) and (isset($downloadentry['fixednzbname'])) and (trim($downloadentry['fixednzbname']) != '')){
                                $strNZBRenamed = $downloadentry['fixednzbname'];
                                @rename($nzbFolder.$strFileNZB, $nzbFolder.$strNZBRenamed);
 	                          }

                            # Write the dummy file
                            @touch($dummy);

                            # Tweet ?
                            if(($twitter_enabled == true) and ($isQueue == false)){

                                $strTweetFinal = str_replace('%download', $downloadentry['title'], $strTweet);
                                $objTwitter->updateStatus($strTweetFinal);

                                # Logging tweet event
                                $_msg = "Tweeting download ".$downloadentry['title'];
                                $objNZBLog->writeLine($_msg);
                                if($run_mode) $run_mode_result .= $_msg."<br />";
                            }

                            # Download succeeded, wegschrijven succesvolle hit
                            $objDownload->set_hit($current_key);

                            # Write log entry
                            $_msg = "Found NZB file for ".$downloadentry['title']." on NZBIndex";
                            if($isQueue) $_msg.=" (add to verification queue)";
                            $objNZBLog->writeLine($_msg);
                            if($run_mode) $run_mode_result .= $_msg."<br />";
                        }else{
                            # Delete file because NZB is invalid
                            unlink($nzbFolder.$strFileNZB);

                            # Write log entry
                            $_msg = "NZB invalid, file deleted!";
                            $objNZBLog->writeLine($_msg);
                            if($run_mode) $run_mode_result .= $_msg."<br />";
                        }
                    }
                }
            }
            # Destroy rss feed object
            unset($objNZBIndexFeed);
        }else{
            # An error occured reading FEED
            $_msg = "Could not load NZBINDEX feed: ".$strNZBIndexFeed;
            $objNZBLog->writeLine($_msg);
            if($run_mode) $run_mode_result .= $_msg."<br />";
        }
    }
    $current_key++;
}

# Logging stop event
$_msg = "Finished checking new NZB files";
if($run_mode){ $_msg.=" (manual)";}else{$_msg.=" (scheduled)";};
$objNZBLog->writeLine($_msg);
if($run_mode) $run_mode_result .= $_msg."<br />";

# Print output in manual mode
if($run_mode) echo "<br />".$run_mode_result."<br />";
?>