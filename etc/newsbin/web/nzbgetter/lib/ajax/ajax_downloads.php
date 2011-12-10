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

# Show downloadlist
$show_list = true;

# Create download list object
$objDownload = new nzbg_conf("download");

# Needs to be save type
if(isset($_GET['type']) and $_GET['type'] == "save"){

    $strDLSource   = $_GET['strDLSource'];
    $strDLTitle    = htmlspecialchars($_GET['strDLTitle']);
    $strDLMatch    = htmlspecialchars($_GET['strDLMatch']);
    $strDLHow      = $_GET['strDLHow'];
    $intMinSize    = (int) $_GET['intMinSize'];

    $strDLQual     = htmlspecialchars($_GET['strDLQual']);

    $arrNew = array("type"         => $strDLSource,
                    "title"        => $strDLTitle,
                    "findstring"   => $strDLMatch,
                    "downloadtype" => $strDLHow);

    if($strDLSource == "tvnzb"){
        $arrNew["quality"] = $strDLQual;
    }

    if($strDLSource =="nzbindex"){
        $arrNew["minsize"] = $intMinSize;
    }

    if(isset($_GET['intMaxSize']) and ($_GET['intMaxSize'] != '')){
        $arrNew["maxsize"] = (int) $_GET['intMaxSize'];
    }

    if(isset($_GET['strPoster']) and ($_GET['strPoster'] != '')){
        $arrNew["poster"] = htmlspecialchars($_GET['strPoster']);
    }

    if(isset($_GET['strExclude']) and ($_GET['strExclude'] != '')){
        $arrNew["excludekeywords"] = htmlspecialchars($_GET['strExclude']);
    }
    
    if(isset($_GET['strNZBFile']) and ($_GET['strNZBFile'] != '')){
    	  $strFixedNZBName = htmlspecialchars($_GET['strNZBFile']);
    	  if(strpos($strFixedNZBName, ".nzb") === false) $strFixedNZBName.=".nzb";
        $arrNew["fixednzbname"] = $strFixedNZBName;
    }

    $arrNew["hits"] = 0;

    $objDownload->add_download($arrNew);

    $appConfig = new nzbg_conf("config");
    $objNZBLog = new nzbg_log($appConfig);
    $objNZBLog->writeLine("Saved entry \"$strDLTitle\" to the download list.");

}elseif(isset($_GET['type']) and $_GET['type'] == "edit"){

    $intID         = $_GET['intID'];
    $strDLOldTitle = $_GET['strOldTitle'];
    $strDLTitle    = htmlspecialchars($_GET['strDLTitle']);
    $strDLMatch    = htmlspecialchars($_GET['strDLMatch']);
    $strDLHow      = $_GET['strDLHow'];

    $arrDownloadList = $objDownload->get_xml_as_array();

    $appConfig = new nzbg_conf("config");
    $objNZBLog = new nzbg_log($appConfig);

    if($arrDownloadList[$intID]['title'] == $strDLOldTitle){
        # Update Queue record
        $arrUpdate = array('title' => $strDLTitle,
                           'findstring' => $strDLMatch,
                           'downloadtype' => $strDLHow);

        # Check type
        if($arrDownloadList[$intID]['type'] == "nzbindex"){
        	  $arrUpdate['excludekeywords'] = htmlspecialchars($_GET['strExclude']);
            $arrUpdate['minsize'] = (int) $_GET['intMinSize'];
            $arrUpdate['maxsize'] = (int) $_GET['intMaxSize'];
            $arrUpdate['poster']  = htmlspecialchars($_GET['strPoster']);
        }elseif($arrDownloadList[$intID]['type'] == "tvnzb"){
            $arrUpdate['quality'] = htmlspecialchars($_GET['strDLQual']);
        }

        if(isset($_GET['strNZBFile']) and (trim($_GET['strNZBFile']) != '')){
    	      $strFixedNZBName = htmlspecialchars($_GET['strNZBFile']);
    	      if(strpos($strFixedNZBName, ".nzb") === false) $strFixedNZBName.=".nzb";
            $arrUpdate['fixednzbname'] = $strFixedNZBName;
        }else{
            $arrUpdate['fixednzbname'] = "";
        }

        $objDownload->edit_download($intID, $arrUpdate);
        $objNZBLog->writeLine("Saved changes for download list entry title ".$strDLTitle);

        echo 1;
    }else{
    	  echo 0;
        $objNZBLog->writeLine("An error occured while savind download entry title ".$strDLTitle);
    }

    # Geen downloadlijst tonen want we zitten in een andere template
    $show_list = false;
}

if($show_list){

    $html = '<br />No items yet<br /><br />';

    $arrDownloadList = $objDownload->get_xml_as_array();

    $counter_tvnzb = 0;
    $counter_nzbindex = 0;

    if(count($arrDownloadList) > 0){

        $html = '<br /><table id="tblDownloadList">';
        $html.= '<thead>';
        $html.= '<tr>';
        $html.= '<th>Source</th>';
        $html.= '<th></th>';
        $html.= '<th>Title</th>';
        $html.= '<th>Match pattern</th>';
        $html.= '<th>Quality / Size</th>';
        $html.= '<th>Hits</th>';
        $html.= '<th>Last hit</th>';
        $html.= '<th>E</th>';
        $html.= '<th>D</th>';
        $html.= '</tr>';
        $html.= '</thead>';
        $html.= '<tbody>';

        foreach($arrDownloadList as $k => $v){

            if($v['type'] == "tvnzb")
                $counter_tvnzb++;
            elseif($v['type'] == "nzbindex")
                $counter_nzbindex++;

            # entries with queue mode are highlighted
            $html.= '<tr>';
            $html.= '<td valign="top">';
            $html.= '<center><img src="images/'.$v['type'].'.png"></center>';
            $html.= '</td>';
            $html.= '<td valign="top">';
            $html.= ($v['downloadtype'] == "queue") ? '<img src="images/icon_queue.png">' : '<img src="images/icon_auto.png">';
            $html.= '</td>';
            $html.= '<td valign="top">';
            $html.= stripslashes($v['title']);
            $html.= '</td>';
            $html.= '<td valign="top">';
            $html.= stripslashes($v['findstring']);
            if(isset($v['poster']) and $v['poster'] != ''){
                $html.="<br /><br /><b>poster:</b> ".$v['poster'];
            }
            $html.= '</td>';
            $html.= '<td valign="top"><center>';

            if($v['type'] == "tvnzb"){

                if($v['quality'] == "HD"){
                    $html.= '<img src="images/hd.png">';
                }else{
                    $html.= 'SD';
                }
            }else{
                $html.= $v['minsize']." MB";
                if($v['maxsize']){
                    $html.= " (max: ".$v['maxsize']." MB)";
                }
            }

            $html.= '</center></td>';
            $html.= '<td valign="top"><center>';
            $html.= isset($v["hits"]) ? $v["hits"] : "0";
            $html.= '</center></td>';
            $html.= '<td valign="top"><center>';
            $html.= isset($v["lastdate"]) ? $v["lastdate"] : "-";
            $html.= '</center></td>';
            $html.= '<td valign="top">';
            $html.= '<center><a href="?a=nzbd&e='.$k.'&t='.urlencode(stripslashes($v["title"])).'"><img src="images/edit.png" border="0"></a></center>';
            $html.= '</td>';
            $html.= '<td valign="top">';
            $html.= '<center><a href="?a=nzbd&d='.$k.'&t='.urlencode(stripslashes($v["title"])).'"><img src="images/remove.png" border="0"></a></center>';
            $html.= '</td>';
            $html.= '</tr>';
        }
        $html.= '</tbody>';
        $html.= '</table><br />';
        $html.= 'Total number of entries: '.$objDownload->count_records()."<br />";
        $html.= 'Total of entries for tvnzb.com: '.$counter_tvnzb."<br />";
        $html.= 'Total of entries for nzbindex.nl: '.$counter_nzbindex;
        $html.= '<br /><br />';
    }

    echo $html;
}
?>