#!/bin/sh
# RMusic CGI routines
# http://geekyhmb.niloo.fr/content/random-music-rss

# Parsing query string provided by the server/client
QUERY=$QUERY_STRING
SAVEIFS=$IFS
IFS="@"
set -- $QUERY
Parm_1=`echo $1`
# full urldecode the Parm_2
Parm_2=$(echo $2 | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')
Parm_2=`echo -n -e $Parm_2`
# end urldecode
Parm_3=`echo $3`
[ -z $Parm_3 ] && Parm_3=0
IFS=$SAVEIFS

CH_Scripts="/usr/local/etc/FBrowser"

DirList()
# List HDD or Usb devices
{
Dir_List="/tmp/FBrowser_dir.list"

echo -e '
<?xml version="1.0" encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

folder=`sed -n '1p' ${Dir_List}`

dirname=${folder%/*}
prevdir=${dirname%/*}

echo $prevdir"/" > ${Dir_List}

cd "$folder"
echo */ " " | sed "s/\/ /\n/g"  >> ${Dir_List}

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

FBrowser()
# File browser
# Original code from DMD RM Jukebox by Martini(CZ) from DMD team
# Contact: w0m@seznam.cz, http://www.hddplayer.cz
# Modified and adapted by zozodesbois from GeekyHMB team
{
echo -e '
<?xml version='1.0' encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  setFullScreenFade(64); 
  FBrowser_Title = "Path";
  FBrowser_Valid = "To Select";
  dirCount=0;
  dir2File = "/tmp/FBrowser_dir.list";
  dirArray = null;
/*  CH_Base = "/tmp/public/"; */
  CH_Base = "/tmp/ramfs/volumes/";
  CH_Sel = CH_Base;
  executeScript("listDir");
  setFocusItemIndex(0);
  RedrawDisplay();
</onEnter>

<onExit>
  /*  postMessage("return"); */
</onExit>

<mediaDisplay name="onePartView" sideLeftWidthPC="0" sideColorLeft="0:0:0" sideRightWidthPC="0" fontSize="14" focusFontColor="210:16:16" itemAlignt="center" viewAreaXPC=29.7 viewAreaYPC=26 viewAreaWidthPC=40 viewAreaHeightPC=50 headerImageWidthPC="0" itemImageHeightPC="0" itemImageWidthPC="0" itemXPC="10" itemYPC="15" itemWidthPC="80" itemHeightPC="10" itemBackgroundColor="0:0:0" itemPerPage="6" itemGap="0" infoYPC="90" infoXPC="90" backgroundColor="0:0:0" showHeader="no" showDefaultInfo="no">
<idleImage> image/POPUP_LOADING_01.png </idleImage>
<idleImage> image/POPUP_LOADING_02.png </idleImage>
<idleImage> image/POPUP_LOADING_03.png </idleImage>
<idleImage> image/POPUP_LOADING_04.png </idleImage>
<idleImage> image/POPUP_LOADING_05.png </idleImage>
<idleImage> image/POPUP_LOADING_06.png </idleImage>
<idleImage> image/POPUP_LOADING_07.png </idleImage>
<idleImage> image/POPUP_LOADING_08.png </idleImage>

<backgroundDisplay>
  <image type="image/jpg" offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=100>
    <script>print("${CH_Scripts}/Modules/FBrowser_Bg.jpg");</script>
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=10 fontSize=14 backgroundColor=-1:-1:-1    foregroundColor=70:140:210>
  <script>print(FBrowser_Title);</script>
</text>

<image redraw="no" offsetXPC="10" offsetYPC="90.5" widthPC="9" heightPC="7.2">
  <script>print("${CH_Scripts}/Modules/play.png");</script>
</image>

<text align="left" offsetXPC=20.5 offsetYPC=89 widthPC=33 heightPC=10 fontSize=12 backgroundColor=-1:-1:-1    foregroundColor=200:200:200>
<script>print(FBrowser_Valid);</script>
</text>

<text redraw="yes" align="center" offsetXPC=2 offsetYPC=75 widthPC=96 heightPC=10 fontSize=10 backgroundColor=0:0:0 foregroundColor=200:150:0>
   <script>
        curidx = getFocusItemIndex();
        if (curidx != 0) {
          New = getStringArrayAt(pathArray, curidx);
        } else {
          New = CH_Sel;
        }
        print(New);
    </script>
</text>

<itemDisplay>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
  if (getDrawingItemState() == "focus") print("${CH_Scripts}/Modules/focus_on.png");
  else print("${CH_Scripts}/Modules/FBrowser_unfocus.png");
    </script>
  </image>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="25" widthPC="8" heightPC="50">
    <script>
            "${CH_Scripts}/Modules/folder.png";
    </script>
  </image>
  <text redraw="yes" offsetXPC="6" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="15">
   <script>
      getStringArrayAt(titleArray , -1);
   </script>
  </text>
</itemDisplay>

<onUserInput>
  userInput = currentUserInput();

  print("KEY PRESSES ISSSSSSSSSSSS ", userInput);
  if ( userInput == "enter" || userInput == "right"){
    curidx = getFocusItemIndex();
    CH_Sel = getStringArrayAt(pathArray, curidx);
    executeScript("listDir");
    setFocusItemIndex(0);
    RedrawDisplay();
    "true";
  } else if ( userInput == "video_play" || userInput == "pagedown" ) {
    curidx = getFocusItemIndex();
    if (curidx != 0) {
      New_CH_Base = getStringArrayAt(pathArray, curidx);
    } else {
      New_CH_Base = CH_Sel;
    }
    setReturnString(New_CH_Base);
    postMessage("return");
    "true";
  } else if ( userInput == "left") {
    setFocusItemIndex(0);
    postMessage("enter");
    "true";
  }
</onUserInput>
</mediaDisplay>

<listDir>
    writeStringToFile(dir2File, CH_Sel);
    dlok = loadXMLFile("http://127.0.0.1/cgi-bin/FBrowser.cgi?DirList");
    test="";
    dirArray=null;
    titleArray=null;
    pathArray=null;
    idx=0;
    dirArray = readStringFromFile(dir2File);
    while (test != " ") {
      if (idx==0) {
        title = "..";
        path = getStringArrayAt(dirArray, idx);
      } else {
        test = getStringArrayAt(dirArray, idx);
        if (test == "*") test = " ";
        if (test != " ") {  
          title = test;
          path = CH_Sel + test + "/";
        }
      }

      titleArray = pushBackStringArray(titleArray,title);
      pathArray = pushBackStringArray(pathArray,path);
      
      idx=Add(idx,1);
    }
    dirCount=idx - 1;
</listDir>

<item_template>
  <displayTitle>
    <script>getStringArrayAt(titleArray , -1);</script>
      </displayTitle>
      <media:thumbnail>
      <script>
        url = "${CH_Scripts}/Modules/folder.png";
        print("thumbnail:");
        print(url);
        url;
      </script>
        </media:thumbnail>
          <media:content type="image/jpeg" />  
    <onClick>
      print("onClick");
    </onClick>
</item_template>
<channel>
  <title></title>
  <itemSize>
     <script>
        dirCount;
     </script>
  </itemSize>
</channel>
</rss>
EOF
}


#***********************Main Program*********************************

case $Parm_1 in
  DirList) DirList;;               # List folders
  FBrowser) FBrowser;;             # Browser interface
  *);;
esac

exit 0
