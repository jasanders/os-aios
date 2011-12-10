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

class nzbg_log{

    private $_log_path;
    private $_logfile_name;
    private $_logfile_handler;
    private $_file_mode;
    private $_config;

    function __construct(nzbg_conf $appConfig){
        $this->_config = $appConfig;
        $this->_logfile_name = $this->_config->logfilename;
        $this->_log_path = $this->_config->_app_root . 'log/';
        $this->openLogFile();
    }

    private function openLogFile(){

        # First let's check if the log file needs to be purged
        if(file_exists( $this->_log_path . $this->_logfile_name )){
            $intLines = count(file( $this->_log_path . $this->_logfile_name ));

            if($intLines > $this->_config->maxloglines) {
                $hndlTemp = fopen( $this->_log_path . $this->_logfile_name , "w");
                fclose($hndlTemp);
            }
        }

        $this->_file_mode = file_exists( $this->_log_path . $this->_logfile_name ) ? "a+" : "w+";
        $this->_logfile_handler = fopen( $this->_log_path . $this->_logfile_name, $this->_file_mode );
    }

    public function writeLine($data){
        # Current formatted date
        fwrite( $this->_logfile_handler, date("d-m-o G:i:s") . ' ' .$data . PHP_EOL );
    }

    function __destruct(){
        fclose( $this->_logfile_handler );
    }
}
?>