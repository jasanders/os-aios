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

class nzbg_curl_download {

    private $curl_handle;
    private $file_handle;
    private $curlopt_timeout;
    private $curlopt_file;
    private $curlopt_followlocation;
    private $url;
    private $path;

    function __construct(){
        $this->curlopt_timeout        = 50;
        $this->curlopt_followlocation = true;
    }

    public function setFrom($url){
        $this->url = $url;
    }

    public function setTo($path){
        $this->path = $path;
    }

    public function download(){
        $this->file_handle = fopen($this->path, 'w+');
        $this->curl_handle = curl_init($this->url);

        curl_setopt($this->curl_handle, CURLOPT_TIMEOUT, $this->curlopt_timeout);
        curl_setopt($this->curl_handle, CURLOPT_FILE, $this->file_handle);
        curl_setopt($this->curl_handle, CURLOPT_FOLLOWLOCATION, $this->curlopt_followlocation);

        curl_exec($this->curl_handle);
    }

    function __destruct(){
        curl_close($this->curl_handle);
        fclose($this->file_handle);
    }
}
?>