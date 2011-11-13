<?php
/*
 
 NZBGetter 1.1a - http://sourceforge.net/projects/nzbgetter/
 Script for linux systems to spider NZB sites to accomplish
 full automated downloading on your Linux (based NAS) system.
 
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

# Load some clas libs
require_once("../classes/nzbg_conf.class.php");
require_once("../classes/nzbg_log.class.php");

# Path to NZB queue
$strPath = dirname(__FILE__)."/../../__exec__/queue/";

# Create objects
$appConfig = new nzbg_conf("config");
$objQueue = new nzbg_conf("queue");
$objNZBLog = new nzbg_log($appConfig);

$arrQueue = $objQueue->get_xml_as_array();

$intID     = $_GET['intID'];
$strOldNZB = htmlspecialchars_decode($arrQueue[$_GET['intID']]['nzb']);
$strNewNZB = strtolower($_GET['strNZBFile']);
$strNewNZB = str_replace("/","-",$strNewNZB);
$strNewNZB = str_replace("&","-",$strNewNZB);

if(strpos($strNewNZB, ".nzb") === false) $strNewNZB.=".nzb";

if(@rename($strPath.$strOldNZB, $strPath.$strNewNZB)){

	# Update Queue record
	$arrUpdate = array('nzb' => htmlspecialchars($strNewNZB));
	$objQueue->edit_download($intID, $arrUpdate);
	$objNZBLog->writeLine("Renamed ".$strOldNZB." to ".$strNewNZB);
    echo 1;
}else{
	$objNZBLog->writeLine("Could not rename ".$strOldNZB);
    echo 0;
}

?>