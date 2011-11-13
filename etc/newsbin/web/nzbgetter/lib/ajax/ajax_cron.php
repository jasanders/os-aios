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

# Locate PHP
$path_to_php = @shell_exec('which php');

# Locate script path
$script_path = dirname(__FILE__);
$script_path = str_replace("lib/ajax","",$script_path);
$script_path.= "__exec__/run.php";

$returnstring = "<b>";

$interval = $_GET['m'];

# Check interval
switch($interval){
    case "15":
        $returnstring .= "*/15 * * * * ";
        break;
    case "30":
        $returnstring .= "*/30 * * * * ";
        break;
    case "60":
        $returnstring .= "0 * * * * ";
        break;
    case "120":
        $returnstring .= "0 */2 * * * ";
        break;
    case "180":
        $returnstring .= "0 */3 * * * ";
        break;
    case "240":
        $returnstring .= "0 */4 * * * ";
        break;
    case "300":
        $returnstring .= "0 */5 * * * ";
        break;
    case "360":
        $returnstring .= "0 */6 * * * ";
        break;
    case "420":
        $returnstring .= "0 */7 * * * ";
        break;
    case "480":
        $returnstring .= "0 */8 * * * ";
        break;
    default:
        $returnstring .= "*/30 * * * * ";
        break;
}

# Create return message
if($path_to_php == ''){
    $returnstring .= "<font color='red'>/path/to/php</font>";
}else{
    $returnstring .= $path_to_php;
}

$returnstring.=" ".$script_path;
$returnstring.="</b>";

# Print out message
echo $returnstring;
?>