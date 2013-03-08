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

class nzbg_template {

    private $_content;
    const replace_str_start = '%%-';
    const replace_str_end   = '-%%';

    function __construct($template) {
        $this->_content = @file_get_contents( 'templates/' . $template . '.html' );
    }

    public function replace($placeholder, $value) {
        $this->_content = str_replace( self::replace_str_start . $placeholder . self::replace_str_end, $value, $this->_content );
    }

    public function replace_array($arrvars) {
        foreach ($arrvars as $k => $v) {
            $this->replace($k, $v);
        }
    }

    public function contents(){
        return $this->_content;
    }

    public function render() {
        echo $this->_content;
    }
}
?>