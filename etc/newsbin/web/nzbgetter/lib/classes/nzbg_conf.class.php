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

class nzbg_conf{

    private $_configFile;
    private $items = array();
    private $_config_type;
    public  $_app_root;

    function __construct($config_file) {
        $this->_app_root    = dirname(__FILE__) . "/../../";
        $this->_config_type = $config_file;
        $this->_configFile  = $this->_app_root . 'conf/nzbg_' . $config_file . '.xml';
        $this->parse_config();
    }

    public function __get($id) {
        return $this->items[ $id ];
    }

    public function get_xml_as_array(){
        return $this->items;
    }

    public function __set($id, $val) {
        $this->items[ $id ] = $val;
    }

    private function parse_config() {
        $doc = new DOMDocument();
        $doc->load( $this->_configFile );

        /* 
          general and config settings are just one-dimensional
          but download list is multi-dimensional, so we need to
          parse the xml structure in a different way
        */

        if($this->_config_type == "download" or $this->_config_type == "queue"){
  
            /*
              Parse the download config which has child nodes
            */

            $cn = $doc->getElementsByTagName( $this->_config_type );

            $counter = 0;

            foreach($cn as $rootElement) {
                if($rootElement->hasChildNodes()){
                    $entries = $rootElement->getElementsByTagName("entry");
                    foreach($entries as $entry){
                        $entrynodes = $entry->getElementsByTagName( "*" );
                        foreach($entrynodes as $entrynode){
                            $this->items[ $counter ][ $entrynode->nodeName ] = $entrynode->nodeValue;
                        }
                        $counter++;
                    }
                }
            }

        }else{
	        
            /*
             Parse the general and settings config which has just single nodes
            */

            $cn = $doc->getElementsByTagName( "config" );

            $nodes = $cn->item(0)->getElementsByTagName( "*" );

            foreach( $nodes as $node ) {
                $this->items[ $node->nodeName ] = $node->nodeValue;
            }
        }
    }

    # This method saves single node config files
    public function save() {
        $doc = new DOMDocument();
        $doc->formatOutput = true;

        $r = $doc->createElement( "config" );
        $doc->appendChild( $r );

        foreach( $this->items as $k => $v )
        {
            $kn = $doc->createElement( $k );
            $kn->appendChild( $doc->createTextNode( $v ) );
            $r->appendChild( $kn );
        }

        copy( $this->_configFile, $this->_configFile.'.bak' );

        $doc->save( $this->_configFile );
    }

    public function add_download($arrDownload){
        array_push($this->items, $arrDownload);
        $this->save_downloads();
    }

    public function set_hit($intID){
        # backward compatibility with version 1.0
        if (array_key_exists('hits', $this->items[$intID]))
            $this->items[$intID]['hits'] = $this->items[$intID]['hits'] + 1;
        else
            $this->items[$intID]['hits'] = 1;

        $this->items[$intID]['lastdate'] = date("d-m-o G:i:s");

        $this->save_downloads();
    }

    public function delete_download($id) {
        unset($this->items[$id]);
        $this->save_downloads();
    }
    
    public function edit_download($id, $arrChanges){

	    $arrKeys = array_keys($arrChanges);

	    foreach($arrKeys as $k){
            $this->items[$id][$k] = $arrChanges[$k];
	    }

	    $this->save_downloads();
    }

    public function count_records(){
        return count($this->items);
    }

    # This method saves the download list
    private function save_downloads() {
        $doc = new DOMDocument();
        $doc->formatOutput = true;

        $r = $doc->createElement( $this->_config_type );
        $doc->appendChild( $r );

        foreach( $this->items as $k_entry => $v_entry ) {

            $entrynode = $doc->createElement( "entry" );

            foreach( $v_entry AS $k => $v ) {

                $entrynode_val = $doc->createElement( $k );
                $entrynode_val->appendChild( $doc->createTextNode( $v ) );
                $entrynode->appendChild( $entrynode_val );
            }

            $r->appendChild( $entrynode );
        }

        copy( $this->_configFile, $this->_configFile.'.bak' );

        $doc->save( $this->_configFile );
    }
}
?>