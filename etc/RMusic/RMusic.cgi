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

CH_Scripts="/usr/local/etc/RMusic"
F_Config="${CH_Scripts}/RMusic.cfg"

# Define shell variable with config file
[ ! -f /tmp/RMusic.cfg ] && sed 's:<\(.*\)>\(.*\)</.*>:\1=\"\2\":' ${F_Config} >/tmp/RMusic.cfg
. /tmp/RMusic.cfg

F_PListLst="${CH_Scripts}/_RMusicPlst.lst"
F_PListCount="${CH_Scripts}/_RMusicPlst.cpt"

UpdateCfg()
# Update the RMusic.cfg
{
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

sed -i "s:<${Parm_3}>.*</${Parm_3}>:<${Parm_3}>${Parm_2}</${Parm_3}>:" "${F_Config}"
sync

sed 's:<\(.*\)>\(.*\)</.*>:\1=\"\2\":' ${F_Config} >/tmp/RMusic.cfg
. /tmp/RMusic.cfg

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

DirList()
# List HDD or Usb devices
{
Dir_List="/tmp/RMusic_Browser_dir.list"

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
  langpath = "${CH_Scripts}/lang/${Language}";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    FBrowser_Title = getXMLText("FBrowser", "FBrowser_Title");
    FBrowser_Valid = getXMLText("FBrowser", "FBrowser_Valid");
  }
  dirCount=0;
  dir2File = "/tmp/RMusic_Browser_dir.list";
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

  if ( userInput == "enter" || userInput == "right"){
    curidx = getFocusItemIndex();
    CH_Sel = getStringArrayAt(pathArray, curidx);
    executeScript("listDir");
    setFocusItemIndex(0);
    RedrawDisplay();
    "true";
  } else if ( userInput == "video_play" ) {
    curidx = getFocusItemIndex();
    if (curidx != 0) {
      New_CH_Base = getStringArrayAt(pathArray, curidx);
    } else {
      New_CH_Base = CH_Sel;
    }
    setEnv("New_Path",New_CH_Base);
    New_CH_Base=urlEncode(New_CH_Base);
    dlok = loadXMLFile("http://127.0.0.1:${Port}/cgi-bin/RMusic.cgi?UpdateCfg@"+New_CH_Base+"@MPath@");
    setReturnString("Update");
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
    dlok = loadXMLFile("http://127.0.0.1:${Port}/cgi-bin/RMusic.cgi?DirList");
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

UpdatingDialog()
# Dialog: Confirm to update
{
echo -e '
<?xml version='1.0' encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  CH_Scripts="/usr/local/etc/RMusic/";
  langfile = loadXMLFile(CH_Scripts+"lang/$Language");
  if (langfile != null) {
    UpdtDialog_Quest = getXMLText("UpdtDialog", "UpdtDialog_Quest");
    UpdtDialog_Confirm = getXMLText("UpdtDialog", "UpdtDialog_Confirm");
  }
</onEnter>

<mediaDisplay name=photoView
   viewAreaXPC=36
   viewAreaYPC=36
   viewAreaWidthPC=27
   viewAreaHeightPC=27
   showHeader=no
   showDefaultInfo=no   
   drawItemBorder = no  
   backgroundColor=-1:-1:-1
   rowCount=1
   columnCount=1
   itemOffsetXPC=30
   itemOffsetYPC=70
   itemHeightPC=70
   centerHeightPC=20
   itemGapXPC=0
   sideTopHeightPC = 0
   bottomYPC = 100
>

<backgroundDisplay>
  <image  offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=100>
    ${CH_Scripts}/Modules/info.png
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=0 offsetYPC=20 widthPC=100 heightPC=13 fontSize=15 backgroundColor=-1:-1:-1 foregroundColor=200:200:200>
  <script>UpdtDialog_Quest;</script>
</text>

<itemDisplay>
  <text align="center" offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=13 fontSize=15 backgroundColor=-1:-1:-1>
  <script>UpdtDialog_Confirm;</script>
  <foregroundColor>
    <script>
      if(getDrawingItemState() == "focus")
        "242:242:0";
      else
        "101:101:101";
    </script>
  </foregroundColor>
  </text>
</itemDisplay>

<onUserInput>
  handled = "false";
  userInput = currentUserInput();
  print("userInput=",userInput);
  focusIndex = getFocusItemIndex();
  if ("enter" == userInput) {
    setReturnString("Confirm");
    postMessage("return");
    handled = "true";
  }
  else if ("edit" == userInput)
  handled = "true";
  handled;
</onUserInput>
</mediaDisplay>

<channel>
<title>Updating Dialog</title>
<link>UpdatingDialog.rss</link>

<itemSize>1</itemSize>

</channel>
</rss>
EOF
}

UpdatingPL()
# Update music list
{
# To kill all childs process when need to stop the script
trap "kill 0" SIGINT

echo -e '
<?xml version='1.0' encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

# to keep alive the RSS
while true; do echo '<k></k>'; sleep 5; done &
TaskChild=$!

cd "$MPath"

# add all musics
find . -print | grep -iE '\.(aac|ac3|aiff|ape|fla|flac|m4a|mka|mp3|ogg|ra|wav|wma)$' | cut -c3- | sed -e 's:\(^.*\)\.\(.*$\):\1\n\2:'> "$F_PListLst"

# number of lines in the file
RMCount=`sed -n '$=' "$F_PListLst"`

if [ -z $RMCount ]; then
  rm "$F_PListLst" 2>/dev/null
  rm "$F_PListCount" 2>/dev/null
else
  expr $RMCount / 2 >"$F_PListCount"
fi

# Force disk buffers to be written
sync

# End the RSS keep alive
kill $TaskChild >/dev/null 2>&1

echo -e '</rss>'
exit 0
}

ImgSearch()
# Search image links on google image result
{
echo -e '
<?xml version='1.0' encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
rm /tmp/RMusic_*.jpg 2>/dev/null

i=0
(sed 's:,:\n:g' /tmp/RMusic_Pict.txt | sed '/\"url\":/!d;s/.*\(http.*\)\"/\1/' | while read line; do let i++; wget -qO /tmp/RMusic_${i}.jpg "${line}" 2>/dev/null; if [ $? -gt 0 ]; then rm /tmp/RMusic_${i}.jpg 2>/dev/null; fi ; done )&

cat <<EOF
<onEnter>
showIdle();
/* setReturnString(CSV_Img); */
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

echo -e '</rss>'
exit 0
}

#***********************Main Program*********************************

case $Parm_1 in
  UpdatingDialog) UpdatingDialog;; # Dialog to confirm update
  UpdatingPL) UpdatingPL;;         # Update playlist
  UpdateCfg) UpdateCfg;;           # Update the cfg file
  DirList) DirList;;               # List folders
  FBrowser) FBrowser;;             # Browser interface
  ImgSearch) ImgSearch;;           # Search image on Google images
  *);;
esac

exit 0
