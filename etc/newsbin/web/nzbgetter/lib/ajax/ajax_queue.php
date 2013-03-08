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

# Create download list object
$objQueue = new nzbg_conf("queue");

# Path to NZB queue
$strPath = dirname(__FILE__)."/../../__exec__/queue/";

$html = '<br />There are currently no NZB files in the queue <br /><br />';

$arrQueue = $objQueue->get_xml_as_array();

if(count($arrQueue) > 0){
	$html = '<br />Total of NZB files in queue: '.$objQueue->count_records();
    $html.= '<br /><br /><table id="tblDownloadList">';
    $html.= '<thead>';
    $html.= '<tr>';
    $html.= '<th>Match on title</th>';
    $html.= '<th>Date of match</th>';
    $html.= '<th>NZB file</th>';
    $html.= '<th>NZB size</th>';
    $html.= '<th></th>';
    $html.= '<th></th>';
    $html.= '</tr>';
    $html.= '</thead>';
    $html.= '<tbody>';
    foreach($arrQueue as $k => $v){
        $html.= '<tr>';
        $html.= '<td>'.$v['matchtitle'];
        $html.= '</td>';
        $html.= '<td>'.$v['datefound'];
        $html.= '</td>';
        $html.= '<td>'.$v['nzb'].' <a href="?a=nzbq&r='.$k.'&t='.urlencode(stripslashes($v["matchtitle"])).'"><img src="images/icon_rename.png" id="test" border="0"></a>';
        $html.= '</td>';
        $html.= '<td>'.@filesize($strPath.$v['nzb']);
        $html.= '</td>';
        $html.= '<td><a href="?a=nzbq&dl='.$k.'&t='.urlencode(stripslashes($v["matchtitle"])).'"><img src="images/download_icon.png" border="0"></a>';
        $html.= '</td>';
        $html.= '<td><a href="?a=nzbq&d='.$k.'&t='.urlencode(stripslashes($v["matchtitle"])).'"><img src="images/remove.png" border="0"></a>';
        $html.= '</td>';
        $html.= '</tr>';
    }
    $html.= '</tbody>';
    $html.= '</table><br />';
}

echo $html;

?>