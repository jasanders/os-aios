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

# Check for cURL support
if(function_exists('curl_init')){
    echo "Wow, thats amazing!\nYou have PHP cURL enabled!\nYou can leave the wget path setting as it is.";
}else{
    # Try to locate WGET
    $wget_path = @shell_exec('which wget');

    if($wget_path != ''){
        echo "Unfortunately your PHP doesn't have cURL enabled.\nBut we found the path you need to enter for this setting:\n\n".$wget_path;
    }else{
        echo "Unfortunately your PHP doesn't have cURL enabled.\nWe could not find the full path to wget on your server. Please check the path on your system by starting a shell command session and enter: 'which wget'. Enter the result of this command as your WGET path.";
    }
}
?>