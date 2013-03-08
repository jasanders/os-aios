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

# Lets write the config file
require_once("../classes/nzbg_conf.class.php");
require_once("../classes/nzbg_log.class.php");

$strWgetFolder      = $_GET['strWgetFolder'];
$strnzbfolder       = $_GET['strNZBFolder'];
$strRSSTvNZB        = $_GET['strRSSTvNZB'];
$strTvNZBHD         = $_GET['strTvNZBHD'];
$strTvNZBSD         = $_GET['strTvNZBSD'];
$strNZBIndex        = $_GET['strNZBIndex'];
$strNZBIndexDays    = $_GET['strNZBIndexDays'];
$strNZBIndexResults = $_GET['strNZBIndexResults'];
$strLogFile         = $_GET['strLogFile'];
$intMaxLinesLog     = $_GET['intMaxLogLines'];
$strTwitterEnabled  = $_GET['strTwitterEnabled'];
$strTwitterUser     = $_GET['strTwitterUser'];
$strTwitterPass     = $_GET['strTwitterPass'];
$strTwitterMessage  = $_GET['strTwitterMessage'];

# Sometimes people forget the last slash, so help those people
if($strnzbfolder[strlen($strnzbfolder)-1] != "/"){
    $strnzbfolder.="/";
}

# Check some input values
if(!file_exists($strnzbfolder)){
    echo 0;
}elseif(!is_numeric($intMaxLinesLog)){
    echo 2;
}elseif(!is_numeric($strNZBIndexDays)){
    echo 3;
}elseif(!is_numeric($strNZBIndexResults)){
    echo 4;
}else{
    $appConfig = new nzbg_conf("config");

    $appConfig->wgetpath        = $strWgetFolder;
    $appConfig->nzbfolder       = $strnzbfolder;
    $appConfig->tvnzbfeed       = htmlspecialchars($strRSSTvNZB);
    $appConfig->tvnzbhd         = htmlspecialchars($strTvNZBHD);
    $appConfig->tvnzbsd         = htmlspecialchars($strTvNZBSD);
    $appConfig->nzbindexfeed    = htmlspecialchars($strNZBIndex);
    $appConfig->nzbindexdays    = htmlspecialchars($strNZBIndexDays);
    $appConfig->nzbindexresults = htmlspecialchars($strNZBIndexResults);
    $appConfig->logfilename     = htmlspecialchars($strLogFile);
    $appConfig->maxloglines     = $intMaxLinesLog;
    $appConfig->twitterenabled  = $strTwitterEnabled;
    $appConfig->twitteruser     = $strTwitterUser;
    $appConfig->twitterpass     = base64_encode("f*bH3jbJHd3@b".$strTwitterPass);
    $appConfig->twittermessage  = $strTwitterMessage;
    $appConfig->save();

    $appSettings = new nzbg_conf("general");

    # First time settings save
    if($appSettings->settingsapplied == 0){
        $appSettings->settingsapplied = 1;
        $appSettings->save();
    }

    $objNZBLog = new nzbg_log($appConfig);
    $objNZBLog->writeLine('Saved new NZBGetter settings');

    echo 1;
}
?>