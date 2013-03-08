<?php
    require_once "remote_keycodes.php";

    $myWebPort = $_SERVER["SERVER_PORT"];
    $myWebHost = $_SERVER["SERVER_NAME"];
    $host = "http://".$myWebHost.":".$myWebPort;
?>
<html>
<head>
<title>The AIOS Remote Control</title>
<script language="JavaScript">
function newwindow(w,h,webaddress,name){
    var viewimageWin = window.open(webaddress,name,"toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,copyhistory=no,width="+w+",height="+h);
    viewimageWin.moveTo(screen.availWidth/2-(w/2),screen.availHeight/2-(h/2));
    window.resizeTo(w, h+80);
}

function Playit(value){
    //alert(value);
    document.playlist.target = 'gframe';
    document.playlist.action = 'play.php?dir='+ value;
    document.playlist.submit();
}

function xmlhttpPost(keycode) {
    var xmlHttpReq = false;
    var self = this;
    var strURL = "http://<?php echo $myWebHost;?>/cgi-bin/iMax?irfake,"+keycode;
    // Mozilla/Safari
    if (window.XMLHttpRequest) {
        self.xmlHttpReq = new XMLHttpRequest();
    }
    // IE
    else if (window.ActiveXObject) {
        self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    self.xmlHttpReq.open('GET', strURL, true);
    self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    self.xmlHttpReq.onreadystatechange = function() {
        //if (self.xmlHttpReq.readyState == 4) {
            //updatepage(self.xmlHttpReq.responseText);
        //}
    }
    self.xmlHttpReq.send();
}
</script>
<link href="includes/style.css" rel="stylesheet" type="text/css">
</head>
<body onload="javascript:moveTo(0,0);window.resizeTo(520,395)" bgcolor="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<form name="remocon" target='gframe' action="rc_action.php" method="post">
<table width="493" height="235" border="0" cellpadding="0" cellspacing="0" align="center">
    <tr>
        <td colspan="48">
            <img src="images/remote_w2_01.png" width="492" height="18" alt=""></td>
        <td>
            <img src="images/spacer.gif" width="1" height="18" alt=""></td>
    </tr>
    <tr>
        <td rowspan="20">
            <img src="images/remote_w2_02.png" width="9" height="216" alt=""></td>
        <td colspan="4">
        <input type="button" style="background: url('images/remote_w2_03.png');background-color:Transparent; height:48px; width:48px; border:none; cursor:hand"
        onclick="javascript:if(confirm('You are about to shutdown the AIOS..., continue?')){xmlhttpPost('<?php echo $key_power;?>');}" name="power"  value=" ">
        </td>
        <td rowspan="13">
            <img src="images/remote_w2_04.png" width="5" height="153" alt=""></td>
        <td colspan="4">
        <input type="button" style="background: url('images/remote_w2_05.png');background-color:Transparent; height:48px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_home;?>');" name="home"  value=" ">
        </td>
        <td colspan="2" rowspan="3">
            <img src="images/remote_w2_06.png" width="4" height="84" alt=""></td>
        <td colspan="5">
        <input type="button" style="background: url('images/remote_w2_07.png');background-color:Transparent; height:48px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_setup;?>');" name="setup"  value=" ">
        </td>
        <td colspan="2" rowspan="2">
            <img src="images/remote_w2_08.png" width="6" height="74" alt=""></td>
        <td>
        <input type="button" style="background: url('images/remote_w2_09.png');background-color:Transparent; height:48px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_zoom;?>');" name="zoom"  value=" ">
        </td>
        <td rowspan="2">
            <img src="images/remote_w2_10.png" width="6" height="74" alt=""></td>
        <td>
        <input type="button" style="background: url('images/remote_w2_11.png');background-color:Transparent; height:48px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_repeat;?>');" name="repeat"  value=" ">
        </td>
        <td rowspan="2">
            <img src="images/remote_w2_12.png" width="4" height="74" alt=""></td>
        <td colspan="2">
        <input type="button" style="background: url('images/remote_w2_13.png');background-color:Transparent; height:48px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_return;?>');" name="return"  value=" ">
        </td>
        <td colspan="23">
            <img src="images/remote_w2_14.png" width="170" height="48" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="48" alt=""></td>
    </tr>
    <tr>
        <td colspan="4" rowspan="2">
            <img src="images/remote_w2_15.png" width="48" height="36" alt=""></td>
        <td colspan="4" rowspan="2">
        <input type="button" style="background: url('images/remote_w2_16.png');background-color:Transparent; height:36px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_up;?>');" name="up"  value=" ">
        </td>
        <td colspan="5" rowspan="2">
            <img src="images/remote_w2_17.png" width="48" height="36" alt=""></td>
        <td>
            <img src="images/remote_w2_18.png" width="48" height="26" alt=""></td>
        <td>
            <img src="images/remote_w2_19.png" width="48" height="26" alt=""></td>
        <td colspan="4">
            <img src="images/remote_w2_20.png" width="57" height="26" alt=""></td>
        <td colspan="5" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_21.png');background-color:Transparent; height:53px; width:46px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_mute;?>');" name="mute"  value=" ">
        </td>
        <td rowspan="14">
            <img src="images/remote_w2_22.png" width="8" height="128" alt=""></td>
        <td colspan="6" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_23.png');background-color:Transparent; height:53px; width:46px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_info;?>');" name="info"  value=" ">
        </td>
        <td rowspan="14">
            <img src="images/remote_w2_24.png" width="6" height="128" alt=""></td>
        <td colspan="7" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_25.png');background-color:Transparent; height:53px; width:46px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_audio;?>');" name="audio"  value=" ">
        </td>
        <td rowspan="19">
            <img src="images/remote_w2_26.png" width="9" height="168" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="26" alt=""></td>
    </tr>
    <tr>
        <td rowspan="18">
            <img src="images/remote_w2_27.png" width="3" height="142" alt=""></td>
        <td colspan="3" rowspan="6">
        <input type="button" style="background: url('images/remote_w2_28.png');background-color:Transparent; height:50px; width:57px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_subtitle;?>');" name="subtitle"  value=" ">
        </td>
        <td colspan="2" rowspan="6">
        <input type="button" style="background: url('images/remote_w2_29.png');background-color:Transparent; height:50px; width:52px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_tvmode;?>');" name="tvmode"  value=" ">
        </td>
        <td colspan="3" rowspan="6">
        <input type="button" style="background: url('images/remote_w2_30.png');background-color:Transparent; height:50px; width:52px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_16_9;?>');" name="16_9"  value=" ">
        </td>
        <td rowspan="18">
            <img src="images/remote_w2_31.png" width="5" height="142" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="10" alt=""></td>
    </tr>
    <tr>
        <td rowspan="10">
            <img src="images/remote_w2_32.png" width="16" height="69" alt=""></td>
        <td colspan="3" rowspan="4">
        <input type="button" style="background: url('images/remote_w2_33.png');background-color:Transparent; height:34px; width:32px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_left;?>');" name="left"  value=" ">
        </td>
        <td colspan="4" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_34.png');background-color:Transparent; height:33px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_enter;?>');" name="enter"  value=" ">
        </td>
        <td rowspan="10">
            <img src="images/remote_w2_35.png" width="2" height="69" alt=""></td>
        <td colspan="4" rowspan="4">
        <input type="button" style="background: url('images/remote_w2_36.png');background-color:Transparent; height:34px; width:32px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_right;?>');" name="right"  value=" ">
        </td>
        <td colspan="2" rowspan="10">
            <img src="images/remote_w2_37.png" width="18" height="69" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="17" alt=""></td>
    </tr>
    <tr>
        <td colspan="5">
            <img src="images/remote_w2_38.png" width="46" height="4" alt=""></td>
        <td colspan="6">
            <img src="images/remote_w2_39.png" width="46" height="4" alt=""></td>
        <td colspan="7">
            <img src="images/remote_w2_40.png" width="46" height="4" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="4" alt=""></td>
    </tr>
    <tr>
        <td rowspan="15">
            <img src="images/remote_w2_41.png" width="5" height="111" alt=""></td>
        <td colspan="2" rowspan="4">
        <input type="button" style="background: url('images/remote_w2_42.png');background-color:Transparent; height:25px; width:37px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_rwd;?>');" name="rwd"  value=" ">
        </td>
        <td colspan="2" rowspan="10">
            <img src="images/remote_w2_43.png" width="4" height="71" alt=""></td>
        <td rowspan="10">
            <img src="images/remote_w2_44.png" width="4" height="71" alt=""></td>
        <td colspan="4" rowspan="4">
        <input type="button" style="background: url('images/remote_w2_45.png');background-color:Transparent; height:25px; width:38px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_play;?>');" name="play"  value=" ">
        </td>
        <td rowspan="10">
            <img src="images/remote_w2_46.png" width="4" height="71" alt=""></td>
        <td colspan="2" rowspan="10">
            <img src="images/remote_w2_47.png" width="5" height="71" alt=""></td>
        <td colspan="4" rowspan="4">
        <input type="button" style="background: url('images/remote_w2_48.png');background-color:Transparent; height:25px; width:38px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_fwd;?>');" name="fwd"  value=" ">
        </td>
        <td rowspan="15">
            <img src="images/remote_w2_49.png" width="3" height="111" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="12" alt=""></td>
    </tr>
    <tr>
        <td colspan="4" rowspan="6">
        <input type="button" style="background: url('images/remote_w2_50.png');background-color:Transparent; height:34px; width:48px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_down;?>');" name="down"  value=" ">
        </td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
    </tr>
    <tr>
        <td colspan="3" rowspan="6">
            <img src="images/remote_w2_51.png" width="32" height="35" alt=""></td>
        <td colspan="4" rowspan="6">
            <img src="images/remote_w2_52.png" width="32" height="35" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="6" alt=""></td>
    </tr>
    <tr>
        <td colspan="8" rowspan="2">
            <img src="images/remote_w2_53.png" width="161" height="11" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="6" alt=""></td>
    </tr>
    <tr>
        <td colspan="2" rowspan="2">
            <img src="images/remote_w2_54.png" width="37" height="11" alt=""></td>
        <td colspan="4" rowspan="2">
            <img src="images/remote_w2_55.png" width="38" height="11" alt=""></td>
        <td colspan="4" rowspan="2">
            <img src="images/remote_w2_56.png" width="38" height="11" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="5" alt=""></td>
    </tr>
    <tr>
        <td colspan="3" rowspan="6">
        <input type="button" style="background: url('images/remote_w2_59.png');background-color:Transparent; height:42px; width:57px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_vol_down;?>');" name="vol_down"  value=" ">
        </td>
        <td colspan="3" rowspan="10">
            <img src="images/remote_w2_58.png" width="53" height="81" alt=""></td>
        <td colspan="2" rowspan="6">
        <input type="button" style="background: url('images/remote_w2_57.png');background-color:Transparent; height:42px; width:51px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_vol_up;?>');" name="vol_up"  value=" ">
        </td>
        <td>
            <img src="images/spacer.png" width="1" height="6" alt=""></td>
    </tr>
    <tr>
        <td colspan="2" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_60.png');background-color:Transparent; height:24px; width:37px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_pageup;?>');" name="pageup"  value=" ">
        </td>
        <td rowspan="4">
            <img src="images/remote_w2_61.png" width="1" height="35" alt=""></td>
        <td colspan="3" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_62.png');background-color:Transparent; height:24px; width:37px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_stop;?>');" name="stop"  value=" ">
        </td>
        <td colspan="3" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_63.png');background-color:Transparent; height:24px; width:37px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_pagedown;?>');" name="pagedown"  value=" ">
        </td>
        <td rowspan="9">
            <img src="images/remote_w2_64.png" width="1" height="75" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="10" alt=""></td>
    </tr>
    <tr>
        <td colspan="4">
            <img src="images/remote_w2_65.png" width="48" height="2" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="2" alt=""></td>
    </tr>
    <tr>
        <td colspan="2" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_66.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_1;?>');" name="1"  value=" ">
        </td>
        <td rowspan="7">
            <img src="images/remote_w2_67.png" width="5" height="63" alt=""></td>
        <td colspan="2" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_68.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_2;?>');" name="2"  value=" ">
        </td>
        <td rowspan="7">
            <img src="images/remote_w2_69.png" width="6" height="63" alt=""></td>
        <td rowspan="3">
        <input type="button" style="background: url('images/remote_w2_70.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_3;?>');" name="3"  value=" ">
        </td>
        <td rowspan="7">
            <img src="images/remote_w2_71.png" width="8" height="63" alt=""></td>
        <td colspan="4" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_72.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_4;?>');" name="4"  value=" ">
        </td>
        <td rowspan="7">
            <img src="images/remote_w2_73.png" width="7" height="63" alt=""></td>
        <td colspan="2" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_74.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_5;?>');" name="5"  value=" ">
        </td>
        <td rowspan="7">
            <img src="images/remote_w2_75.png" width="7" height="63" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="12" alt=""></td>
    </tr>
    <tr>
        <td colspan="2">
            <img src="images/remote_w2_76.png" width="37" height="11" alt=""></td>
        <td colspan="3">
            <img src="images/remote_w2_77.png" width="37" height="11" alt=""></td>
        <td colspan="3">
            <img src="images/remote_w2_78.png" width="37" height="11" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="11" alt=""></td>
    </tr>
     <tr>
        <td rowspan="3">
        <input type="button" style="background: url('images/remote_w2_79.png');background-color:Transparent; height:18px; width:27px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_red;?>');" name="red"  value=" ">
        </td>
        <td colspan="2" rowspan="5">
            <img src="images/remote_w2_80.png" width="12" height="40" alt=""></td>
        <td colspan="5" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_81.png');background-color:Transparent; height:18px; width:27px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_green;?>');" name="green"  value=" ">
        </td>
        <td rowspan="5">
            <img src="images/remote_w2_82.png" width="12" height="40" alt=""></td>
        <td colspan="4" rowspan="3">
        <input type="button" style="background: url('images/remote_w2_83.png');background-color:Transparent; height:18px; width:27px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_yellow;?>');" name="yellow"  value=" ">
        </td>
        <td colspan="2" rowspan="5">
            <img src="images/remote_w2_84.png" width="10" height="40" alt=""></td>
        <td rowspan="3">
        <input type="button" style="background: url('images/remote_w2_85.png');background-color:Transparent; height:18px; width:27px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_blue;?>');" name="blue"  value=" ">
        </td>
        <td rowspan="5">
            <img src="images/remote_w2_86.png" width="1" height="40" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
    </tr>
    <tr>
        <td colspan="2">
            <img src="images/remote_w2_87.png" width="24" height="6" alt=""></td>
        <td colspan="2">
            <img src="images/remote_w2_88.png" width="24" height="6" alt=""></td>
        <td>
            <img src="images/remote_w2_89.png" width="24" height="6" alt=""></td>
        <td colspan="4">
            <img src="images/remote_w2_90.png" width="24" height="6" alt=""></td>
        <td colspan="2">
            <img src="images/remote_w2_91.png" width="24" height="6" alt=""></td>
        <td colspan="3" rowspan="4">
            <img src="images/remote_w2_92.png" width="57" height="39" alt=""></td>
        <td colspan="2" rowspan="4">
            <img src="images/remote_w2_93.png" width="51" height="39" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="6" alt=""></td>
    </tr>
    <tr>
        <td colspan="2" rowspan="2">
        <input type="button" style="background: url('images/remote_w2_94.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_6;?>');" name="6"  value=" ">
        </td>
        <td colspan="2" rowspan="2">
        <input type="button" style="background: url('images/remote_w2_95.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_7;?>');" name="7"  value=" ">
        </td>
        <td rowspan="2">
        <input type="button" style="background: url('images/remote_w2_96.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_8;?>');" name="8"  value=" ">
        </td>
        <td colspan="4" rowspan="2">
        <input type="button" style="background: url('images/remote_w2_97.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_9;?>');" name="9"  value=" ">
        </td>
        <td colspan="2" rowspan="2">
        <input type="button" style="background: url('images/remote_w2_98.png');background-color:Transparent; height:24px; width:24px; border:none; cursor:hand"
        onclick="javascript:xmlhttpPost('<?php echo $key_0;?>');" name="0"  value=" ">
        </td>
        <td>
            <img src="images/spacer.png" width="1" height="11" alt=""></td>
    </tr>
    <tr>
        <td rowspan="2">
            <img src="images/remote_w2_99.png" width="27" height="22" alt=""></td>
        <td colspan="5" rowspan="2">
            <img src="images/remote_w2_100.png" width="27" height="22" alt=""></td>
        <td colspan="4" rowspan="2">
            <img src="images/remote_w2_101.png" width="27" height="22" alt=""></td>
        <td rowspan="2">
            <img src="images/remote_w2_102.png" width="27" height="22" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="13" alt=""></td>
    </tr>
    <tr>
        <td colspan="2">
            <img src="images/remote_w2_103.png" width="24" height="9" alt=""></td>
        <td colspan="2">
            <img src="images/remote_w2_104.png" width="24" height="9" alt=""></td>
        <td>
            <img src="images/remote_w2_105.png" width="24" height="9" alt=""></td>
        <td colspan="4">
            <img src="images/remote_w2_106.png" width="24" height="9" alt=""></td>
        <td colspan="2">
            <img src="images/remote_w2_107.png" width="24" height="9" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="9" alt=""></td>
    </tr>
    <tr>
        <td>
            <img src="images/spacer.png" width="9" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="16" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="8" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="5" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="19" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="5" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="6" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="24" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="8" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="10" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="2" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="2" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="10" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="7" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="13" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="11" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="7" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="3" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="3" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="48" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="6" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="48" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="4" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="47" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="4" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="5" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="5" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="27" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="10" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="2" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="2" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="8" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="4" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="12" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="12" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="13" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="4" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="6" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="4" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="9" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="27" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="1" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="3" height="1" alt=""></td>
        <td>
            <img src="images/spacer.png" width="9" height="1" alt=""></td>
        <td></td>
    </tr>
</table>
</form>

<div class="remote">
<a href="./remote_v.php" onfocus="this.blur()">
(Vertical)</a>
</div>

<!-- End Save for Web Slices -->
<iframe name='gframe' width=0 height=0 style="display:none"></iframe>
<div id="loadDiv" name="loadDiv" style="position:absolute; visibility:hidden; left:30;top:120;width:200; height:100; z-index:1;">
    <table cellspacing="0" cellpadding="0" border="0" width=100% height=100%>
        <td valign=middle align=center>
            <table borde=0 align=center>
                <td align=center>
                    <img src="dlf/upload.gif">
                </td>
            </table>
        </td>
    </table>
</div>

</body>
</html>
