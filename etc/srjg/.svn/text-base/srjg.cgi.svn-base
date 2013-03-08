#!/bin/sh
# Simple RSS Jukebox Generator
# http://code.google.com/p/srjg/

# To kill all childs process when need to stop the script
trap "kill 0" SIGINT

# Parsing query string provided by the server/client
QUERY=$QUERY_STRING
SAVEIFS=$IFS
IFS="@"
set -- $QUERY
mode=`echo $1`
# full urldecode the CategoryTitle
CategoryTitle=$(echo $2 | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')
CategoryTitle=`echo -n -e $CategoryTitle`
Jukebox_Size=`echo $3`
Parm_4=`echo $4`
[ -z $Parm_4 ] && Parm_4=0
Parm_5=`echo $5`
[ -z $Parm_5 ] && Parm_5=0
Parm_6=`echo $6`
[ -z $Parm_6 ] && Parm_6=0
IFS=$SAVEIFS
Search=${CategoryTitle}

# Setting up variable according to srjg.cfg file
. /tmp/srjg.cfg

# Setting up other variable
if [ "${SingleDb}" = "yes" ]; then 
  Database="${Jukebox_Path}movies.db"
  UpdateLog="${Jukebox_Path}update.log"
  PreviousMovieList="${Jukebox_Path}prevmovies.list"
else
  Database="${Movies_Path}SRJG/movies.db"
  UpdateLog="${Movies_Path}SRJG/update.log"
  ([ -d "${Movies_Path}" ] && [ ! -d "${Movies_Path}SRJG/" ]) && mkdir -p "${Movies_Path}SRJG/"
  PreviousMovieList="${Movies_Path}SRJG/prevmovies.list"
fi

if ([ "${Nfo_Path}" = "SRJG" ] || [ "${Sheet_Path}" = "SRJG" ] || [ "${Poster_Path}" = "SRJG" ]) ; then
  ([ -d "${Movies_Path}" ] && [ ! -d "${Movies_Path}SRJG/ImgNfo/" ]) && mkdir -p "${Movies_Path}SRJG/ImgNfo/"
  FSrjg_Path="${Movies_Path}SRJG/ImgNfo" # Possible storage for images and Nfo files to let clean the Movies_Path folder
fi

Sqlite=${Jukebox_Path}"sqlite3"
MoviesList="/tmp/srjg_movies.list"
InsertList="/tmp/srjg_insert.list"
DeleteList="/tmp/srjg_delete.list"
ExluList="/tmp/srjg_exclu.list"

# Genre "All Movies" depending of the language
AllMovies=`sed "/>All Movies|/!d;s:|\(.*\)>.*:\1:" "${Jukebox_Path}lang/${Language}_genre"`

SetVar()
{
# Settting up a few variables needed

[ $mode = "genreSelection" ] && nextmode="genre";
[ $mode = "yearSelection" ] && nextmode="year";
[ $mode = "alphaSelection" ] && nextmode="alpha";

if [ $mode = "genre" ] || [ $mode = "year" ] || [ $mode = "alpha" ] || [ $mode = "recent" ] || [ $mode = "notwatched" ] || [ $mode = "moviesearch" ]; then
  nextmode="moviesheet";
fi
}

CreateMovieDB()
{
# Create the Movie Database
# DB as an automatic datestamp but unfortunately it relies on the player having the
# correct date which can be trivial with some players.

${Sqlite} "${Database}" "create table t1 (Movie_ID INTEGER PRIMARY KEY AUTOINCREMENT,genre TEXT,title TEXT,year TEXT,path TEXT,file TEXT,ext TEXT,watched INTEGER,dateStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
${Sqlite} "${Database}" "create table t2 (header TEXT, footer TEXT, IdMovhead TEXT, IdMovFoot TEXT,WatchedHead TEXT, WatchedFoot TEXT)";
${Sqlite} "${Database}" "insert into t2 values ('<item>','</item>','<IdMovie>','</IdMovie>','<Watched>','</Watched>')";
}

Force_DB_Creation()
{
# Force creation of the Database using the "u" parameter option
# This option can be use to start up with a fresh database in case of
# Database corruption

rm "${PreviousMovieList}" 2>/dev/null # The /dev/null if list not exist due to rss update
rm "${Database}" 2>/dev/null
CreateMovieDB;
}


Infoparsing()
{
# Parse nfo file to extract movie title, genre and year

# Look for lines matching <title>
while read LINE
do
  # Strip out <title> to make it shorter.
  SHORT="${LINE#<title>}"
  # If it's not shorter, it didn't have <title>
  if [ "${#SHORT}" = "${#LINE}" ]; then continue ; fi
  MOVIETITLE="$SHORT"
  break   # Found <title>, quit looking
done <"$NFOPATH/$INFONAME"

# if genre not exist <genre />
GENRE=`sed -e '/<genre>/,/\/genre>/!d;/genre>/d' -f "${Jukebox_Path}lang/${Language}_genreGrp" "$NFOPATH/$INFONAME"`
MovieYear=`sed '/<year>/!d;s:.*>\(.*\)</.*:\1:' "$NFOPATH/$INFONAME"`            
}

GenerateMovieList()
{
# Find the movies based on movie extension and path provided.
# Remove movies: 
# - That contains the string(s) specified in $Movie_Filter
# - In all path that contains files exclu.txt

# Replace the comma in Movie_Filter to pipes |
Movie_Filter=`echo ${Movie_Filter} | sed 's/,/|/ g'`

find "${Movies_Path}" \
  | egrep -i 'exclu.txt|\.(asf|avi|dat|divx|flv|img|iso|m1v|m2p|m2t|m2ts|m2v|m4v|mkv|mov|mp4|mpg|mts|qt|rm|rmp4|rmvb|tp|trp|ts|vob|wmv)$' \
  | egrep -iv "${Movie_Filter}" > ${MoviesList}

# create exclu path list
sed '/exclu.txt/!d;s:\(.*/\)\([^/]*\):\\\#\1\#d:' ${MoviesList} >${ExluList}
# remove exlu path
[ -s "${ExluList}" ] && sed -i -f ${ExluList} ${MoviesList}
}

GenerateInsDelFiles()
{
# Generate insertion and deletion files

sed -i -e 's/\[/\&lsqb;/g' -e 's/\]/\&rsqb;/g' $MoviesList # Conversion of [] for grep
if [ -s $MoviesList ]; then
  if [ -s "${PreviousMovieList}" ] ; then # because the grep -f don't work with empty file
    grep -vf $MoviesList "${PreviousMovieList}" | sed -e 's/\&lsqb;/\[/g' -e 's/\&rsqb;/\]/g' > $DeleteList
    grep -vf "${PreviousMovieList}" $MoviesList | sed -e 's/\&lsqb;/\[/g' -e 's/\&rsqb;/\]/g' > $InsertList
  else
    cat $MoviesList | sed -e 's/\&lsqb;/\[/g' -e 's/\&rsqb;/\]/g' > $InsertList
  fi
else
  cat "${PreviousMovieList}" | sed -e 's/\&lsqb;/\[/g' -e 's/\&rsqb;/\]/g' > $DeleteList
fi
mv $MoviesList "${PreviousMovieList}"
}

DBMovieDelete()
{
# Delete records from the movies.db database.

echo "Removing movies from the Database ...."
while read LINE
do
  MOVIEPATH="${LINE%/*}"  # Shell builtins instead of dirname
  MOVIEFILE="${LINE##*/}" # Shell builtins instead of basename
  MOVIEEXT="${MOVIEFILE##*.}"  # only ext
  MOVIEFILE="${MOVIEFILE%.*}"  # Strip off .ext

  ${Sqlite} "${Database}"  "DELETE from t1 WHERE file='<file>${MOVIEFILE}</file>' AND path='<path>${MOVIEPATH}</path>' AND ext='<ext>${MOVIEEXT}</ext>'";
done < $DeleteList
${Sqlite} "${Database}"  "VACUUM";
}

DBMovieInsert()
{
# Add movies to the Database and extract movies posters/folders

rm "${UpdateLog}" 2>/dev/null
while read LINE
do
  MOVIEPATH="${LINE%/*}"  # Shell builtins instead of dirname
  MOVIEFILE="${LINE##*/}" # Shell builtins instead of basename
  MOVIENAME="${MOVIEFILE%.*}"  # Strip off .ext
  MOVIEEXT="${MOVIEFILE##*.}"  # only ext

  if [ "${Nfo_Path}" = "MoviesPath" ]; then NFOPATH="${MOVIEPATH}"; 
  elif [ "${Nfo_Path}" = "SRJG" ]; then NFOPATH="${FSrjg_Path}"
  else NFOPATH="${Nfo_Path}"; fi

  # Initialize defaults, replace later
  MOVIETITLE="$MOVIENAME</title>"
  GENRE="<name>Unknown</name>"
  MovieYear=""

  if [ -e "$NFOPATH/MovieInfo.nfo" ]; then INFONAME=MovieInfo.nfo;
  else INFONAME=$MOVIENAME.nfo; fi

  [ -e "$NFOPATH/$INFONAME" ] && Infoparsing

  if [ -z "$GENRE" ]; then dbgenre="<name>Unknown</name>"; else dbgenre="$GENRE"; fi
  dbtitle=`echo "<title>$MOVIETITLE" | sed "s/'/''/g"`
  dbpath=`echo "<path>$MOVIEPATH</path>" | sed "s/'/''/g"`
  dbfile=`echo "<file>$MOVIENAME</file>" | sed "s/'/''/g"`
  dbext=`echo "<ext>$MOVIEEXT</ext>" | sed "s/'/''/g"`
  dbYear=$MovieYear

  if [ "$Force_DB_Update" = "y" ]; then
    dbdateStamp=`date -r "$MOVIEPATH/$MOVIENAME.$MOVIEEXT" '+%Y-%m-%d %H:%M:%S'`
    ${Sqlite} "${Database}" \
      "insert into t1 (genre,title,year,path,file,ext,dateStamp) \
      values ('$dbgenre','$dbtitle','$dbYear','$dbpath','$dbfile','$dbext','$dbdateStamp');";
  else
    ${Sqlite} "${Database}" \
      "insert into t1 (genre,title,year,path,file,ext) \
      values ('$dbgenre','$dbtitle','$dbYear','$dbpath','$dbfile','$dbext');";
  fi
done < $InsertList
}

Update()
{
# Will update the Database based on the parameters in srjg.cfg

Header;
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
EOF

# to keep alive the RSS
while true; do echo '<k></k>'; sleep 5; done &
TaskChild=$!

GenerateMovieList;

[ "$Imdb" = "yes" ] &&  ${Jukebox_Path}imdb.sh RSS_mode
[ -n "$Force_DB_Update" ] && Force_DB_Creation
[ ! -f "${Database}" ] && CreateMovieDB
GenerateInsDelFiles;
[[ -s $DeleteList ]] && DBMovieDelete
[[ -s $InsertList ]] && DBMovieInsert

# Force disk buffers to be written
sync

# End the RSS keep alive
kill $TaskChild >/dev/null 2>&1

echo '<channel>'
Footer;
}

WatcheUpDB()
{
# Update the watched field in the Database.

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

watch="${Jukebox_Size}"
if [ "${watch}" = "1" ]; then watch="1"; else watch=""; fi # write "" instead of 0 if not watched

${Sqlite} "${Database}" "UPDATE t1 set Watched='$watch' WHERE Movie_ID like '$CategoryTitle'";
echo '<channel></channel></rss>' # to close the RSS
exit 0
}

Header()
{
#Insert RSS Header

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
}

Footer()
{
#Insert RSS Footer

cat <<EOF
</channel>
</rss>
EOF
}

UpdateMenu()
{
#Display UpdateMenu

echo -e '
<?xml version="1.0"   encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
		langpath = "${Jukebox_Path}lang/${Language}";
		langfile = loadXMLFile(langpath);
		if (langfile != null)
		{
			update_fast = getXMLText("update", "fast");
      update_rebuild = getXMLText("update", "rebuild");
		}
</onEnter>

<mediaDisplay name="photoView" rowCount="2" columnCount="1" drawItemText="no" showHeader="no" showDefaultInfo="no" menuBorderColor="255:255:255" sideColorBottom="-1:-1:-1" sideColorTop="-1:-1:-1" itemAlignt="left" itemOffsetXPC="41" itemOffsetYPC="75" itemWidthPC="20" itemHeightPC="7.2" backgroundColor="-1:-1:-1" itemBackgroundColor="-1:-1:-1" sliding="no" itemGap="0" idleImageXPC="90" idleImageYPC="5" idleImageWidthPC="5" idleImageHeightPC="8" imageUnFocus="null" imageParentFocus="null" imageBorderPC="0" forceFocusOnItem="no" cornerRounding="yes" itemBorderColor="-1:-1:-1" focusBorderColor="-1:-1:-1" unFocusBorderColor="-1:-1:-1">
<idleImage> image/POPUP_LOADING_01.png </idleImage>
<idleImage> image/POPUP_LOADING_02.png </idleImage>
<idleImage> image/POPUP_LOADING_03.png </idleImage>
<idleImage> image/POPUP_LOADING_04.png </idleImage>
<idleImage> image/POPUP_LOADING_05.png </idleImage>
<idleImage> image/POPUP_LOADING_06.png </idleImage>
<idleImage> image/POPUP_LOADING_07.png </idleImage>
<idleImage> image/POPUP_LOADING_08.png </idleImage>
<itemDisplay>

<image type="image/png" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
 <script>
  if (getDrawingItemState() == "focus")
  {
      print("${Jukebox_Path}images/focus_on.png");
  }
 else
  {
      print("${Jukebox_Path}images/focus_off.png");
  }
 </script>
</image>

<text redraw="no" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="16" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>  

<onUserInput>

  userInput = currentUserInput();

  if (userInput == "right") {
    "true";
  } else if (userInput == "enter") {
    postMessage("return");
    "false";
  }

</onUserInput>
</mediaDisplay>

<channel>
<title>Updating</title>

<item>
<title><script>update_fast;</script></title>
<link>http://127.0.0.1:$Port/cgi-bin/srjg.cgi?Update@Fast@$Jukebox_Size</link>
</item>

<item>
<title><script>update_rebuild;</script></title>
<link>http://127.0.0.1:$Port/cgi-bin/srjg.cgi?Update@Rebuild@$Jukebox_Size</link>
</item>

</channel>
</rss>
EOF
}

DisplayRss()
{
#Display many of the RSS required based on various parameters/variables

if [ $Jukebox_Size = "2x6" ]; then
   row="2"; col="6"; itemWidth="14.06"; itemHeight="35.42"; itemXPC="5.5"; itemYPC="12.75";
elif [ $Jukebox_Size = "sheetwall" ]; then
   row="1"; col="8"; itemWidth="10.3"; itemHeight="20"; itemXPC="5.5"; itemYPC="80";
elif [ $Jukebox_Size = "sheetmovie" ]; then
   row="1"; col="8"; itemWidth="10.3"; itemHeight="20"; itemXPC="5.5"; itemYPC="20";
else
   row="3"; col="8"; itemWidth="10.3"; itemHeight="23.42"; itemXPC="5.5"; itemYPC="12.75";
fi

# return the sheetmovie watched array to previous 
if [ $Jukebox_Size = "sheetmovie" ]; then
cat <<EOF
<onEnter>
  redrawDisplay();
  displayInfos = "false";
</onEnter>
<onExit>
  setEnv("EAWatched", AWatched);
  setEnv("EAWatched_size", AWatched_size);
  playItemURL(-1, 1);                              /* Stop the video on exit */
</onExit>
EOF

else

cat <<EOF
	<onEnter>
    displayInfos = "false";
    EAWatched=getEnv("EAWatched");
    EAWatched_size=getEnv("EAWatched_size");
    if ( EAWatched_size &gt; 0 ){
      /* adding the Env array from the sheetmovie to update the local array */
      ToggleEAWatched="off";
      j=0;
      while (j &lt; EAWatched_size){
        MovieID = getStringArrayAt(EAWatched,j);
        j += 1;
        Item_Watched = getStringArrayAt(EAWatched,j);
        j += 1;
        executeScript("WatchUpdate");
      }
      setEnv("EAWatched", "");
      setEnv("EAWatched_size", 0);
    }
    redrawDisplay();
  </onEnter>

<onExit>
  playItemURL(-1, 1);                              /* Stop the video on exit */
</onExit>
EOF
fi

cat <<EOF
	<script>
	    Config = "/usr/local/etc/srjg.cfg";
		Config_ok = loadXMLFile(Config);
		if (Config_ok == null) {
			Jukebox_Path = "/usr/local/etc/srjg/";
			Language = "en";
        }
		else {
			Jukebox_Path = getXMLText("Config", "Jukebox_Path");
			Language = getXMLText("Config", "Lang");
		}
		
		DefaultView = getXMLText("Config", "Jukebox_Size");
            Category_Title = "$CategoryTitle";
	    Category_Background = "${Jukebox_Path}images/background.jpg";
            setFocusItemIndex($Parm_4);
            Current_Item_index=0;
            Genre_Title = Category_Title;
	    Jukebox_Size ="$Jukebox_Size";
	    mode = "$mode";
	    nextmode = "$nextmode";
		
		langpath = Jukebox_Path + "lang/" + Language;
		langfile = loadXMLFile(langpath);
		if (langfile != null)
		{
			jukebox_helpGP = getXMLText("jukebox", "helpGP");
      jukebox_helpJbx = getXMLText("jukebox", "helpJbx");
      jukebox_helpSheet = getXMLText("jukebox", "helpSheet");
		}

    /* array to keep update Watchcgi during views */
    AWatched="";
    AWatched_size=0;
    ToggleEAWatched="on";
    setEnv("EAWatched", "");
    setEnv("EAWatched_size", 0);
    Cd2 = "false";
    EndPlay="false";
	</script>

<mediaDisplay name="photoView" rowCount="$row" columnCount="$col" imageFocus="null" showHeader="no" showDefaultInfo="no" drawItemBorder="no" viewAreaXPC="0" viewAreaYPC="0" viewAreaWidthPC="100" viewAreaHeightPC="100" itemGapXPC="0.7" itemGapYPC="1" itemWidthPC="$itemWidth" itemHeightPC="$itemHeight" itemOffsetXPC="$itemXPC" itemOffsetYPC="$itemYPC" itemBorderPC="0" itemBorderColor="7:99:176" itemBackgroundColor="-1:-1:-1" sideTopHeightPC="0" sideBottomHeightPC="0" bottomYPC="100" idleImageXPC="67.81" idleImageYPC="89.17" idleImageWidthPC="4.69" idleImageHeightPC="4.17" backgroundColor="0:0:0">

		<idleImage> image/POPUP_LOADING_01.png </idleImage>
		<idleImage> image/POPUP_LOADING_02.png </idleImage>
		<idleImage> image/POPUP_LOADING_03.png </idleImage>
		<idleImage> image/POPUP_LOADING_04.png </idleImage>
		<idleImage> image/POPUP_LOADING_05.png </idleImage>
		<idleImage> image/POPUP_LOADING_06.png </idleImage>
		<idleImage> image/POPUP_LOADING_07.png </idleImage>
		<idleImage> image/POPUP_LOADING_08.png </idleImage>
EOF

if ([ $Jukebox_Size = "2x6" ] || [ $Jukebox_Size = "3x8" ]); then		
cat <<EOF
		<backgroundDisplay>
            <script>
                 Jukebox_itemSize = getPageInfo("itemCount"); 
			</script>
			<image type="image/jpeg" redraw="no" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
				<script>
					print(Category_Background);
				</script>
		  	</image>      
		</backgroundDisplay>   

		<text redraw="no" align="center" offsetXPC="2.5" offsetYPC="3" widthPC="90" heightPC="10" fontSize="20" backgroundColor="-1:-1:-1" foregroundColor="192:192:192">
			<script>
			    print(Category_Title);
			</script>
		</text>
EOF

elif [ $Jukebox_Size = "sheetwall" ]; then
cat <<EOF
		<backgroundDisplay>
    <script>
      Jukebox_itemSize = getPageInfo("itemCount"); 
    </script>    
		</backgroundDisplay>
		
		<image type="image/jpeg" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="80">
  <script>
    if ( "${Sheet_Path}" == "MoviesPath" ) ItemPath = getItemInfo(-1, "path");
    else if ( "${Sheet_Path}" == "SRJG" ) ItemPath = "${FSrjg_Path}";
    else ItemPath = "${Sheet_Path}";
    ItemFile = getItemInfo(-1, "file");
    SheetPath = ItemPath +"/"+ ItemFile +"_sheet.jpg";
    Etat = readStringFromFile(SheetPath);
    if (Etat==null) SheetPath = "${Jukebox_Path}images/NoMovieinfo.jpg";
    SheetPath;
  </script>
</image>

<!-- Display watched icon -->
<image type="image/png" redraw="yes" offsetXPC="4" offsetYPC="4" widthPC="10" heightPC="10">
<script>
  MovieID=getItemInfo(-1, "IdMovie");
  AWatched_found="false";
  AWatched_state="";
	i=0;
	while(i &lt; AWatched_size ){
    if (MovieID == getStringArrayAt(AWatched,i)) {
      AWatched_found="true";
      AWatched_state=getStringArrayAt(AWatched,add(i,1));
      break;
    }
		i += 2;
	}
  if ( AWatched_found == "true") {
    if ( AWatched_state == "1" ) "${Jukebox_Path}images/watched.png";
  } else {
    if (getItemInfo(-1, "Watched") == "1") "${Jukebox_Path}images/watched.png";
  }
</script>

</image>
<!-- Display 2cd icon -->
<image type="image/png" redraw="yes" offsetXPC="86" offsetYPC="4" widthPC="10" heightPC="10">
<script>
  MovieTitle=getItemInfo(-1, "file");
  FindCd1=findString(MovieTitle, "cd1");
  if ( FindCd1 == "cd1" ) "${Jukebox_Path}images/2cd.png";
</script>
</image>
EOF

else  # sheetmovie
cat <<EOF
<backgroundDisplay>
  <script>
    Jukebox_itemSize = getPageInfo("itemCount"); 
  </script>    
</backgroundDisplay>
		
<image type="image/jpeg" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
  <script>
    if ( "${Sheet_Path}" == "MoviesPath" ) ItemPath = getItemInfo(-1, "path");
    else if ( "${Sheet_Path}" == "SRJG" ) ItemPath = "${FSrjg_Path}";
    else ItemPath = "${Sheet_Path}";
    ItemFile = getItemInfo(-1, "file");
    SheetPath = ItemPath +"/"+ ItemFile +"_sheet.jpg";
    Etat = readStringFromFile(SheetPath);
    if (Etat==null) SheetPath = "${Jukebox_Path}images/NoMovieinfo.jpg";
    SheetPath;
  </script>
</image>


<!-- Display watched icon -->
<image type="image/png" redraw="yes" offsetXPC="4" offsetYPC="4" widthPC="10" heightPC="10">
<script>
  MovieID=getItemInfo(-1, "IdMovie");
  AWatched_found="false";
  AWatched_state="";
	i=0;
	while(i &lt; AWatched_size ){
    if (MovieID == getStringArrayAt(AWatched,i)) {
      AWatched_found="true";
      AWatched_state=getStringArrayAt(AWatched,add(i,1));
      break;
    }
		i += 2;
	}
  if ( AWatched_found == "true") {
    if ( AWatched_state == "1" ) "${Jukebox_Path}images/watched.png";
  } else {
    if (getItemInfo(-1, "Watched") == "1") "${Jukebox_Path}images/watched.png";
  }
</script>
</image>

<!-- Display 2cd icon -->
<image type="image/png" redraw="yes" offsetXPC="86" offsetYPC="4" widthPC="10" heightPC="10">
<script>
  MovieTitle=getItemInfo(-1, "file");
  FindCd1=findString(MovieTitle, "cd1");
  if ( FindCd1 == "cd1" ) "${Jukebox_Path}images/2cd.png";
</script>
</image>
EOF
fi

# BEGIN Display help
cat <<EOF
  <image type="image/png" redraw="no" offsetXPC="0" offsetYPC="0">
  <widthPC>
    <script>
      if(displayInfos == "true") 100;
      else 0;
    </script>
  </widthPC>
  <heightPC>
    <script>
      if(displayInfos == "true") 100;
      else 0;
    </script>
  </heightPC>
    <script>
      print(Jukebox_Path + "images/focus_on.png");
    </script>
  </image>

	<text redraw="yes" align="left" lines="15" fontSize="15" offsetXPC="23" offsetYPC="18" heightPC="70" backgroundColor="-1:-1:-1" foregroundColor="200:200:200">
		<widthPC>
			<script>
				if(displayInfos == "true") 55;
        else 0;
			</script>
		</widthPC>
		<script>
EOF

if [ $mode = "genreSelection" ] || [ $mode = "alphaSelection" ] || [ $mode = "yearSelection" ]; then
  echo 'jukebox_helpGP;';
else
  if [ $Jukebox_Size = "sheetmovie" ]; then
    echo 'jukebox_helpSheet;'
  else
    echo 'jukebox_helpJbx;'
  fi
fi

cat <<EOF
		</script>
	</text>
EOF

if ([ $mode = "genreSelection" ] || [ $mode = "alphaSelection" ] || [ $mode = "yearSelection" ]); then
cat <<EOF	
		<image type="image/jpeg" redraw="yes" offsetXPC="80" offsetYPC="5.5" widthPC="8" heightPC="6">
				<script>
					print("${Jukebox_Path}images/"+Jukebox_Size+".jpg");
				</script>
    </image>
EOF
fi
	
cat <<EOF
	<onUserInput>
				userInput = currentUserInput();

				Current_Item_index=getFocusItemIndex();
				Max_index = (-1 + Jukebox_itemSize);
				Prev_index = (-1 + Current_Item_index);
				Next_index = (1 + Current_Item_index);
				Prev10_index = (-10 + Current_Item_index);
				Next10_index = (10 + Current_Item_index);

    if (displayInfos == "true") {
      if (userInput == "enter" || userInput == "return" || userInput == "display") {
        displayInfos = "false";
      	redrawDisplay();
      }
      "true";
    } else {
        if (userInput == "display") {
	    	  displayInfos = "true";
	      	redrawDisplay();
          "true";
        } else if (userInput == "pageup" &amp;&amp; Current_Item_index &gt; 9) {
					setFocusItemIndex(Prev10_index); 
					"true";
					redrawDisplay();
				} else if (userInput == "pagedown"  &amp;&amp; Current_Item_index &lt; (Max_index - 9)) {
					setFocusItemIndex(Next10_index); 
					"true";
					redrawDisplay();
				} else if (userInput == "left") {
					"false";
				} else if (userInput == "right") {
					"false";                                 
        } else if (userInput == "enter") {
          if ( "$Jukebox_Size" == "sheetmovie" ) {
            M_ID=getItemInfo(-1, "IdMovie");
            M_File=getItemInfo(-1, "file");
            M_Path=getItemInfo(-1, "path");
            M_Ext=getItemInfo(-1, "ext");
            Current_Movie_File=M_Path +"/"+ M_File +"."+ M_Ext;
            Cd2 = "false";
            executeScript("PlayMovie");
					} else if (nextmode == "moviesheet") {
             Item_Pos=getFocusItemIndex();
					   Genre_Title=urlEncode("$CategoryTitle");
             jumpToLink("ViewSheet");
          } else {
					   Genre_Title=urlEncode(getItemInfo(-1, "title"));
					   jumpToLink("NextView");
          }
				  "false";
				}
EOF

	if ([ $mode = "genreSelection" ] || [ $mode = "alphaSelection" ] || [ $mode = "yearSelection" ]); then
cat <<EOF	
				else if (userInput == "one") {
          Genre_Title=urlEncode(Genre_Title); 
					executeScript("SwitchView");
					"false";
					redrawDisplay();
				}
EOF
fi

if ([ $mode != "genreSelection" ] && [ $mode != "alphaSelection" ] && [ $mode != "yearSelection" ]); then
cat <<EOF
        else if (userInput == "two") {
          MovieID=getItemInfo(-1, "IdMovie"); 
          Item_Watched=getItemInfo(-1, "Watched"); /* get item info before exiting rss */
          executeScript("WatchUpdate"); /* update array AWatched */
					jumpToLink("Watchcgi"); /* update watched state in database */
					"false";
				}
        else if (userInput == "edit") {
          MovieID=getItemInfo(-1, "IdMovie");
          MTitle=getItemInfo(-1, "title");
          setEnv("MTitle", MTitle);
					if ( "$UnlockRM" == "yes" ) jumpToLink("MenuEdit"); /* Display MenuEdit  */
					"true";
				}
EOF
else
cat <<EOF
        else if (userInput == "edit") {
					"true";
				}
EOF
fi

if ([ $mode != "genreSelection" ] && [ $mode != "alphaSelection" ] && [ $mode != "yearSelection" ]); then
cat <<EOF
        else if (userInput == "video_play") {
          M_ID=getItemInfo(-1, "IdMovie");
          M_File=getItemInfo(-1, "file");
          M_Path=getItemInfo(-1, "path");
          M_Ext=getItemInfo(-1, "ext");
          Current_Movie_File=M_Path +"/"+ M_File +"."+ M_Ext;
          Cd2 = "false";
          executeScript("PlayMovie");
					"false";
        } else if (userInput == "video_completed" ) {
          FindCd1=findString(M_File, "cd1");
          if ( FindCd1 == "cd1" ) {
            M_File=urlEncode(M_File); 
            jumpToLink("ReplaceCd1byCd2"); /* replace cd1 by cd2 into M_File */
            M_File=getEnv( "MovieCd2" );
            Current_Movie_File=M_Path +"/"+ M_File +"."+ M_Ext;
            playItemURL(-1, 1);              /* reset play */
            Cd2 = "true";
            executeScript("PlayMovie"); /* play cd2 */
          }
          if ( Cd2 == "false" ) {
            Item_Watched="1"; /* mark item as watched */
            EndPlay="true";
			  		ToggleEAWatched = "off"; /* don't toggle watched */
            MovieID=M_ID;
            executeScript("WatchUpdate"); /* update array AWatched */
            jumpToLink("Watchcgi"); /* update watched state in database */
          } else Cd2 = "false";
					"false";
        } else if (userInput == "video_search") {
					SelNum=doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?NumberEdit@"+Jukebox_itemSize+"@60@85@0@Seek");
          if ( SelNum != 0 ) {
            SelNum -= 1;
				  	setFocusItemIndex(SelNum);
				  	redrawDisplay();
          }
          "false";
        }
EOF
fi

cat <<EOF
      }
		</onUserInput>
EOF

if ([ $Jukebox_Size = "2x6" ] ||  [ $Jukebox_Size = "3x8" ]); then
cat <<EOF 
<!-- Show Folder Name -->
<text offsetXPC="7" offsetYPC="88.8" widthPC="75" heightPC="5" fontSize="14" useBackgroundSurface="yes" foregroundColor="195:196:195" redraw="yes" lines="1">
 <script>
    displayTitle = getItemInfo(-1, "title"); 
    displayTitle;
 </script>
</text>

<!-- Show Page Info -->
<text offsetXPC="82" offsetYPC="88.8" widthPC="10" heightPC="5" fontSize="14" foregroundColor="195:196:195" useBackgroundSurface="yes" redraw="yes" lines="1" align="right">
 <script>
  pageInfo = Add(getFocusItemIndex(),1) + "/" + Jukebox_itemSize;
  pageInfo;
 </script>
</text>
<itemDisplay>
EOF

else
cat <<EOF 
<itemDisplay>
EOF

fi

cat <<EOF 
<!-- Bottom Layer focus/unfocus -->
<image type="image/jpeg" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
EOF

cat <<EOF
 <script>
  if (getDrawingItemState() == "focus")
  { if (getItemInfo(-1, "Watched") == "1") {
      "${Jukebox_Path}images/focus_watched.jpg";
      }
    else {
      "${Jukebox_Path}images/focus.jpg";
      }
  }
  else
  { if (getItemInfo(-1, "Watched") == "1") {
      "${Jukebox_Path}images/unfocus_watched.jpg";
      }
    else {
      "${Jukebox_Path}images/unfocus.jpg";
      }
  }
 </script>
</image>
EOF


if [ "$mode" = "yearSelection" ]; then
cat <<EOF
<!-- Top Layer folder.jpg -->
<image type="image/jpeg" offsetXPC="8.2" offsetYPC="5.5" widthPC="84.25" heightPC="89.25">
 <script>
  thumbnailPath = "${Jukebox_Path}images/yearfolder.jpg";
  thumbnailPath;
 </script>
</image>
<text offsetXPC="4" offsetYPC="16" widthPC="105" heightPC="20" fontSize="12" align="center" foregroundColor="0:0:0">
<script>
	getItemInfo(-1, "title");
</script>
</text>
EOF

else

cat <<EOF
<!-- Top Layer folder.jpg -->
<image type="image/jpeg" redraw="yes" offsetXPC="8.2" offsetYPC="5.5" widthPC="84.25" heightPC="89.25">
 <script>
  if ( "${Poster_Path}" == "MoviesPath" || "$mode" == "genreSelection" || "$mode" == "alphaSelection" ) ItemPath = getItemInfo(-1, "path");
  else if ("${Poster_Path}" == "SRJG") ItemPath = "${FSrjg_Path}";
  else ItemPath = "${Poster_Path}";
  ItemFile = getItemInfo(-1, "file");
  thumbnailPath = ItemPath +"/"+ ItemFile +".jpg";
  Etat = readStringFromFile(thumbnailPath);
  if (Etat==null) thumbnailPath = "${Jukebox_Path}images/nofolder.jpg";
  thumbnailPath;
 </script>
</image>

<!-- Display watched icon -->
<image type="image/png" redraw="yes" offsetXPC="3.2" offsetYPC="3.0" widthPC="20" heightPC="15">
<script>
  MovieID=getItemInfo(-1, "IdMovie");
  AWatched_found="false";
  AWatched_state="";
	i=0;
	while(i &lt; AWatched_size ){
    if (MovieID == getStringArrayAt(AWatched,i)) {
      AWatched_found="true";
      AWatched_state=getStringArrayAt(AWatched,add(i,1));
      break;
    }
		i += 2;
	}
  if ( AWatched_found == "true") {
    if ( AWatched_state == "1" ) "${Jukebox_Path}images/watched.png";
  } else {
    if (getItemInfo(-1, "Watched") == "1") "${Jukebox_Path}images/watched.png";
  }
</script>
</image>

<!-- Display 2cd icon -->
<image type="image/png" redraw="yes" offsetXPC="75" offsetYPC="4" widthPC="20" heightPC="15">
<script>
  MovieTitle=getItemInfo(-1, "file");
  FindCd1=findString(MovieTitle, "cd1");
  if ( FindCd1 == "cd1" ) "${Jukebox_Path}images/2cd.png";
</script>
</image>
EOF

if ([ "$mode" = "genreSelection" ] && [ "$Dspl_Genre_txt" != "no" ]); then
cat <<EOF
<text offsetXPC="1" offsetYPC="75" widthPC="98" heightPC="13" fontSize="13" align="center">
<foregroundColor>
  <script>
	  if ( "$Dspl_Genre_txt" == "white") "255:255:255";
		else "0:0:0";
  </script>
</foregroundColor>
<script>
	getItemInfo(-1, "title");
</script>
</text>
EOF

  fi # if "$mode" = "genreSelection"
fi

cat <<EOF
</itemDisplay>
</mediaDisplay>

<NextView>
    <link>
       <script>
			print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?"+nextmode+"@"+Genre_Title+"@"+Jukebox_Size);
       </script>
    </link>
</NextView>

<SRJGView>
    <link>
       <script>
			print(Jukebox_Path + "SrjgMainMenu.rss");
       </script>
    </link>
</SRJGView>
EOF

if ([ $mode != "genreSelection" ] && [ $mode != "alphaSelection" ] && [ $mode != "yearSelection" ]); then
cat <<EOF
<ViewSheet>
    <link>
       <script>
          print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?"+mode+"@"+Genre_Title+"@sheetmovie@"+Item_Pos);
       </script>
    </link>
</ViewSheet>
EOF
fi

if ([ $mode = "genreSelection" ] || [ $mode = "alphaSelection" ] || [ $mode = "yearSelection" ]); then
cat <<EOF
<SwitchView>
  if( Jukebox_Size == "2x6" ) Jukebox_Size="3x8";
	else if( Jukebox_Size == "3x8") Jukebox_Size="sheetwall";
	else Jukebox_Size="2x6";
</SwitchView>
EOF
fi

cat <<EOF
<ReplaceCd1byCd2>
    <link>
       <script>
           print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?ReplaceCd1byCd2@"+M_File+"@");
       </script>
    </link>
</ReplaceCd1byCd2>

<Watchcgi>
    <link>
       <script>
           print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?WatcheUpDB@"+MovieID+"@"+Watched);
       </script>
    </link>
</Watchcgi>

<MenuEdit>
    <link>
       <script>
           print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?MenuEdit@"+MovieID+"@");
       </script>
    </link>
</MenuEdit>

<WatchUpdate>
  /* find if also watched, remove it and do nothing, else add the modified state into array */
  AWatched_found="false";
  TmpTst = "false";
  i=0;
  while(i &lt; AWatched_size ){
    TmpID=getStringArrayAt(AWatched,i);
    TmpW=getStringArrayAt(AWatched,add(i,1));
    if (TmpW == "1" &amp;&amp; EndPlay == "true" ) {
      TmpTst = "true";
    } else TmpTst = "false";
    if (MovieID == TmpID) {
      if ( TmpTst == "false" ){
        AWatched=deleteStringArrayAt(AWatched, i);
        AWatched=deleteStringArrayAt(AWatched, i);
        AWatched_size -=2;
      }
      AWatched_found="true";
      break;
    }
  	i += 2;
  }
  if (ToggleEAWatched == "on" &amp;&amp; TmpTst == "false") {
    if (Item_Watched == "1") { Watched = 0; } else { Watched = 1; } /* toggle watch */
  } else {
    if (Item_Watched == "1") { Watched = 1; } else { Watched = 0; }
  }
  if ( AWatched_found != "true" ) {
    AWatched=pushBackStringArray(AWatched, MovieID);
    AWatched=pushBackStringArray(AWatched, Watched);
    AWatched_size +=2;
  } else if (Item_Watched == "1") { Watched = 1; } else { Watched = 0; } /* reset toggle watch */
	ToggleEAWatched = "on";
  EndPlay="false";
</WatchUpdate>

<PlayMovie>
  RecentFile = "${Jukebox_Path}recently_played";
  writeStringToFile(RecentFile, Current_Movie_File);
  UE_MovieFile=urlEncode(Current_Movie_File);
  UE_Srt=urlEncode(M_Path +"/"+ M_File);
  SubTitle="false";
  DontPlay="false";
  if ( M_Ext == "iso" || M_Ext == "ISO" ) { 
    playItemURL(Current_Movie_File, 0);
  } else {
    /* search subt */
    dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?srtList@"+UE_Srt);
    M_SubSrt = readStringFromFile( "/tmp/srjg_srt_dir.list" );
    if ( M_SubSrt != "" &amp;&amp; M_SubSrt != null ) { /* subt exists */
      SubTSel="";
       if ( "$Subt_OneAuto" == "yes" &amp;&amp; ( getStringArrayAt(M_SubSrt,1) == null || getStringArrayAt(M_SubSrt,1) == "" )) SubTSel=getStringArrayAt(M_SubSrt,0);
       else SubTSel=doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?MenuSubT@"+MovieID+"@");
      if ( SubTSel != "nosubtitle" &amp;&amp; SubTSel != "" &amp;&amp; SubTSel != null ) {
        UE_Srt=urlEncode(SubTSel);
        dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?SubTitleGen@"+UE_Srt+"@");
        SubTitle="true";
      } else if ( SubTSel == "" || SubTSel == null ) DontPlay="true";
    }
    /* Play movie */
    if (DontPlay == "false") doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?PlayMovie@"+UE_MovieFile+"@"+SubTitle);
  }
</PlayMovie>

<channel>
	<title><script>Category_Title;</script></title>
	<link><script>Category_RSS;</script></link>
	<itemSize><script>Jukebox_itemSize;</script></itemSize>
EOF

if [ "$mode" = "genre" ]; then
   if [ "$Search" = "$AllMovies" ]; then
     ${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 ORDER BY title COLLATE NOCASE"; # All Movies
   else
      ${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 WHERE genre LIKE '%$Search%' ORDER BY title COLLATE NOCASE";
   fi   
fi

if [ "$mode" = "alpha" ]; then
if [ "$Search" = "0-9" ]; then
${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 WHERE title LIKE '<title>9%' OR title LIKE '<title>8%' OR title LIKE '<title>7%' OR title LIKE '<title>6%' OR title LIKE '<title>5%' OR title LIKE '<title>4%' OR title LIKE '<title>3%' OR title LIKE '<title>2%' OR title LIKE '<title>1%' OR title LIKE '<title>0%'";
else
${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 WHERE title LIKE '<title>$Search%' ORDER BY title COLLATE NOCASE";
fi
fi

if [ "$mode" = "year" ]; then
${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 WHERE year ='$Search' ORDER BY title COLLATE NOCASE";
fi

if [ "$mode" = "recent" ]; then
${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 ORDER BY datestamp DESC LIMIT "$Recent_Max;
fi

if [ "$mode" = "notwatched" ]; then
${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 WHERE watched <>'1' OR watched IS NULL ORDER BY title COLLATE NOCASE";
fi

if [ "$mode" = "moviesearch" ]; then
${Sqlite} -separator ''  "${Database}"  "SELECT header,IdMovhead,Movie_ID,IdMovFoot,title,path,file,ext,WatchedHead,watched,WatchedFoot,footer FROM t1,t2 WHERE title LIKE '<title>%$Search%' ORDER BY title COLLATE NOCASE";
fi

if [ "$mode" = "yearSelection" ]; then
# pulls out the years of the movies
${Sqlite} -separator ''  "${Database}"  "SELECT DISTINCT year FROM t1 ORDER BY year DESC" > /tmp/srjg_year.list
while read LINE
do
echo "<item>"
echo "<title>"$LINE"</title>"
echo "</item>"
done < /tmp/srjg_year.list
fi


if [ "$mode" = "genreSelection" ]; then
  # pulls out the genre of the movies
  # The first line does the following: Pull data from database; remove all leading/trailing white spaces; sort and remove duplicate
  # remove possible empty line that may exist; remove any blank line
  # that may be still present.
  ${Sqlite} -separator ''  "${Database}"  "SELECT genre FROM t1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sort -u | sed '/<name/!d;s:.*>\(.*\)</.*:\1:' | grep "[!-~]" > /tmp/srjg_genre.list

  # Add "All Movies" depending of the language, into the genre list
  sed -i 1i"$AllMovies" /tmp/srjg_genre.list
  while read LINE
  do
		# translate to find genre thumbnails
    Img_genre=`sed "/|${LINE}>/!d;s:.*>\(.*\)|:\1:" "${Jukebox_Path}lang/${Language}_genre"`
    if [ -z "$Img_genre" ]; then Img_genre=${LINE}; fi
    if [ ! -e "${Jukebox_Path}images/genre/$Img_genre.jpg" ]; then Img_genre="Unknown"; fi
cat <<EOF
    <item>
    <title>${LINE}</title>
    <path>${Jukebox_Path}images/genre</path>
    <file>$Img_genre</file>
    </item>
EOF
  done < /tmp/srjg_genre.list
fi

if [ "$mode" = "alphaSelection" ]; then
# pulls out the first letter of alphabet of the movie title
# The first line does the following: Pull data from database; remove the leading and trailing <title></title>; cut the title first 
# Character; remove anything that is not A-Z ex: a number; sort and remove duplicate.
${Sqlite} -separator ''  "${Database}"  "SELECT title FROM t1" | sed '/<title/!d;s:.*>\(.*\)</.*:\1:' | cut -c 1 | grep '[0-9A-Z]' | sort -u > /tmp/srjg_alpha.list
iteration="0";
while read LINE
do
if [ $LINE -eq $LINE 2> /dev/null ]; then   
if [ $iteration = "0" ]; then
iteration="1";
echo "<item>"
echo "<title>"0-9"</title>"
echo "<path>"${Jukebox_Path}"images/alpha</path>"
echo "<file>JukeMenu_Number</file>"
echo "</item>"
fi
else
echo "<item>"
echo "<title>"$LINE"</title>"
echo "<path>"${Jukebox_Path}"images/alpha</path>"
echo "<file>JukeMenu_"$LINE"</file>"
echo "</item>"
fi
done < /tmp/srjg_alpha.list
fi
}

LoadCfg()
{
# Load settings from /usr/local/etc/srjg.cfg

cat <<EOF
	Config = "/usr/local/etc/srjg.cfg";
  Config_ok = loadXMLFile(Config);
    
	if (Config_ok == null) {
		print("Load Config fail ", Config);
	} else {
    Language = getXMLText("Config", "Lang");
		Jukebox_Path = getXMLText("Config", "Jukebox_Path");
		Jukebox_Size = getXMLText("Config", "Jukebox_Size");
		Movies_Path = getXMLText("Config", "Movies_Path");
		Nfo_Path = getXMLText("Config", "Nfo_Path");
		Poster_Path = getXMLText("Config", "Poster_Path");
		Sheet_Path = getXMLText("Config", "Sheet_Path");
    UnlockRM = getXMLText("Config", "UnlockRM");
    SingleDb = getXMLText("Config", "SingleDb");
		Movie_Filter = getXMLText("Config", "Movie_Filter");
		Port = getXMLText("Config", "Port");
		Recent_Max = getXMLText("Config", "Recent_Max");
		Dspl_Genre_txt = getXMLText("Config", "Dspl_Genre_txt");
		Subt_OneAuto = getXMLText("Config", "Subt_OneAuto");
		Subt_FontPath = getXMLText("Config", "Subt_FontPath");
		Subt_FontFile = getXMLText("Config", "Subt_FontFile");
		Subt_Color = getXMLText("Config", "Subt_Color");
		Subt_ColorBg = getXMLText("Config", "Subt_ColorBg");
		Subt_Size = getXMLText("Config", "Subt_Size");
		Subt_Pos = getXMLText("Config", "Subt_Pos");
    Imdb = getXMLText("Config", "Imdb");
		Imdb_Lang = getXMLText("Config", "Imdb_Lang");
		Imdb_Source = getXMLText("Config", "Imdb_Source");
		Imdb_Poster = getXMLText("Config", "Imdb_Poster");
		Imdb_PBox = getXMLText("Config", "Imdb_PBox");
		Imdb_PPost = getXMLText("Config", "Imdb_PPost");
		Imdb_Sheet = getXMLText("Config", "Imdb_Sheet");
		Imdb_SBox = getXMLText("Config", "Imdb_SBox");
		Imdb_SPost = getXMLText("Config", "Imdb_SPost");
		Imdb_Backdrop = getXMLText("Config", "Imdb_Backdrop");
		Imdb_Font = getXMLText("Config", "Imdb_Font");
		Imdb_Genres = getXMLText("Config", "Imdb_Genres");
    Imdb_Tagline = getXMLText("Config", "Imdb_Tagline");
    Imdb_Time = getXMLText("Config", "Imdb_Time");
    Imdb_Info = getXMLText("Config", "Imdb_Info");
    Imdb_MaxDl = getXMLText("Config", "Imdb_MaxDl");
  }
EOF
}

SaveTmpCfg()
{
# Save settings to /tmp/srjg.cfg

cat <<EOF
  srjgconf="/tmp/srjg.cfg";
  tmpconfigArray=null;
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Language="+Language);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Jukebox_Path="+Jukebox_Path);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Movies_Path="+Movies_Path);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Nfo_Path="+Nfo_Path);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Poster_Path="+Poster_Path);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Sheet_Path="+Sheet_Path);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "SingleDb="+SingleDb);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "UnlockRM="+UnlockRM);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Movie_Filter="+Movie_Filter);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Port="+Port);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Recent_Max="+Recent_Max);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Dspl_Genre_txt="+Dspl_Genre_txt);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_OneAuto="+Subt_OneAuto);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_FontPath="+Subt_FontPath);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_FontFile="+Subt_FontFile);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_Color="+Subt_Color);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_ColorBg="+Subt_ColorBg);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_Size="+Subt_Size);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_Pos="+Subt_Pos);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb="+Imdb);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Lang="+Imdb_Lang);
	tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Source="+Imdb_Source);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Poster="+Imdb_Poster);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_PBox="+Imdb_PBox);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_PPost="+Imdb_PPost);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Sheet="+Imdb_Sheet);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_SBox="+Imdb_SBox);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_SPost="+Imdb_SPost);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Backdrop="+Imdb_Backdrop);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Font="+Imdb_Font);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Genres="+Imdb_Genres);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Tagline="+Imdb_Tagline);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Time="+Imdb_Time);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_Info="+Imdb_Info);
  tmpconfigArray=pushBackStringArray(tmpconfigArray, "Imdb_MaxDl="+Imdb_MaxDl);
  writeStringToFile(srjgconf, tmpconfigArray);
EOF
}

DsplCfgEdit()
{
# RSS to edit Display

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
EOF

LoadCfg
SaveTmpCfg

cat <<EOF
  langpath = Jukebox_Path + "lang/" + Language;
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    Lang_Dspl_Genre_txt = getXMLText("Dspl", "Dspl_Genre_txt");
		Lang_Subt_OneAuto = getXMLText("Subt", "Subt_OneAuto");
		Lang_Subt_FontPath = getXMLText("Subt", "Subt_FontPath");
		Lang_Subt_FontFile = getXMLText("Subt", "Subt_FontFile");
		Lang_Subt_Color = getXMLText("Subt", "Subt_Color");
		Lang_Subt_ColorBg = getXMLText("Subt", "Subt_ColorBg");
		Lang_Subt_Size = getXMLText("Subt", "Subt_Size");
		Lang_Subt_Pos = getXMLText("Subt", "Subt_Pos");
		Lang_No = getXMLText("cfg", "no");
		Lang_Yes = getXMLText("cfg", "yes");
		Lang_White = getXMLText("cfg", "white");
		Lang_Black = getXMLText("cfg", "black");
		Lang_Yellow = getXMLText("cfg", "yellow");
		Lang_Transparent = getXMLText("cfg", "transparent");
  }

  Version = readStringFromFile(Jukebox_Path + "Version");
  if ( Version == null ) print ("Version File not found");

  if ( Subt_FontPath == "JukeboxPath" ) FontPath=Jukebox_Path+"font/";
  else FontPath = Subt_FontPath;

  redrawDisplay();
</onEnter>

<mediaDisplay name="photoView" rowCount="8" columnCount="1" drawItemText="no" showHeader="no" showDefaultInfo="no" menuBorderColor="255:255:255" sideColorBottom="-1:-1:-1" sideColorTop="-1:-1:-1" itemAlignt="left" itemOffsetXPC="4" itemOffsetYPC="32" itemWidthPC="32" itemHeightPC="7.2" backgroundColor="-1:-1:-1" itemBackgroundColor="-1:-1:-1" sliding="no" itemGap="0" idleImageXPC="90" idleImageYPC="5" idleImageWidthPC="5" idleImageHeightPC="8" imageUnFocus="null" imageParentFocus="null" imageBorderPC="0" forceFocusOnItem="no" cornerRounding="yes" itemBorderColor="-1:-1:-1" focusBorderColor="-1:-1:-1" unFocusBorderColor="-1:-1:-1">
<idleImage> image/POPUP_LOADING_01.png </idleImage> 
<idleImage> image/POPUP_LOADING_02.png </idleImage> 
<idleImage> image/POPUP_LOADING_03.png </idleImage> 
<idleImage> image/POPUP_LOADING_04.png </idleImage> 
<idleImage> image/POPUP_LOADING_05.png </idleImage> 
<idleImage> image/POPUP_LOADING_06.png </idleImage> 
<idleImage> image/POPUP_LOADING_07.png </idleImage> 
<idleImage> image/POPUP_LOADING_08.png </idleImage> 

<!-- comment menu display -->
<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="35" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( Dspl_Genre_txt == "no" ) print( Lang_No );
    else if ( Dspl_Genre_txt == "white" ) print( Lang_White );
		else print( Lang_Black );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="43" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( Subt_OneAuto == "no" ) print( Lang_No );
		else print( Lang_Yes );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="51" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print( Subt_FontPath );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="59" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print( Subt_FontFile );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="67" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( Subt_Color == "white" ) print( Lang_White );
		else print( Lang_Yellow );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="75" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( Subt_ColorBg == "black" ) print( Lang_Black );
		else print( Lang_Transparent );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="83" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print( Subt_Size );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="91" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print( Subt_Pos );
	</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      mode=getItemInfo(indx, "selection");
      if ( mode == "Subt_FontFile" ) {
        FontSel="";
        dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?FontList@");
        M_FontFile = readStringFromFile( "/tmp/srjg_font_dir.list" );
        if ( M_FontFile != "" &amp;&amp; M_FontFile != null ) { /* Font file exists */
          if ( getStringArrayAt(M_FontFile,1) == null || getStringArrayAt(M_FontFile,1) == "" ) FontSel=getStringArrayAt(M_FontFile,0);
          else FontSel=doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?MenuFont@");
        }
        if ( FontSel !="" &amp;&amp; FontSel != null ) {
          UE_FontSel=urlEncode(FontSel);
          dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+UE_FontSel+"@Subt_FontFile@");
        }
        executeScript("onEnter");
      } else if ( mode == "Subt_FontPath" ) {
        SelParam=getItemInfo(indx, "param");
        YPos=getItemInfo(indx, "pos");
        setEnv("New_Path","");
        dlok = doModalRss("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?"+mode+"@"+SelParam+"@"+YPos+"@"+XPos);
        New_Path=getEnv("New_Path");
        if ( New_Path != "" &amp;&amp; New_Path != null ) {
          if ( Subt_FontPath != New_Path ) { /* save new tmp cfg */
            srjgconf="/tmp/srjg.cfg";
            tmpconfigArray=readStringFromFile(srjgconf);
            tmpconfigArray=pushBackStringArray(tmpconfigArray, "Subt_FontPath='"+New_Path+"'");
            writeStringToFile(srjgconf, tmpconfigArray);
          }
          FontSel="";
          dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?FontList@");
          M_FontFile = readStringFromFile( "/tmp/srjg_font_dir.list" );
          if ( M_FontFile != null ) { /* Font file exists */
            if ( getStringArrayAt(M_FontFile,1) == null || getStringArrayAt(M_FontFile,1) == "" ) FontSel=getStringArrayAt(M_FontFile,0);
            else FontSel=doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?MenuFont@");
          }
          if ( FontSel != null ) {
            UE_FontSel=urlEncode(FontSel);
            dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+UE_FontSel+"@Subt_FontFile@");
          } else {
            Tst_File = readStringFromFile( FontPath+Subt_FontFile );
            if ( Tst_File == null ) dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@@Subt_FontFile@");
          }
        }
        executeScript("onEnter");
      } else {
        SelParam=getItemInfo(indx, "param");
        YPos=getItemInfo(indx, "pos");
        jumpToLink("SelectionEntered");
			}
      "false";
    }
  </script>
</onUserInput>

 
<itemDisplay>

<image type="image/png" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
 <script>
  if (getDrawingItemState() == "focus") print(Jukebox_Path + "images/focus_on.png");
  else print(Jukebox_Path + "images/focus_off.png");
 </script>
</image>

<text redraw="no" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="16" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>  

   <backgroundDisplay>
        <image type="image/jpeg" redraw="no" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
	     <script>
                 print(Jukebox_Path + "images/srjgMainMenu.jpg");
             </script>
        </image>
    </backgroundDisplay> 

</mediaDisplay>

<SelectionEntered>
    <link>
       <script>
           print("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?"+mode+"@"+SelParam+"@"+YPos+"@"+XPos);
       </script>
    </link>
</SelectionEntered>

<channel>
<title>Display menu</title>

<item>
<title>
	<script>
		print(Lang_Dspl_Genre_txt);
	</script>
</title>
<selection>Dspl_Genre_txt</selection>
<param>no%20white%20black</param>
<pos>25</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_OneAuto);
	</script>
</title>
<selection>Subt_OneAuto</selection>
<param>no%20yes</param>
<pos>35</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_FontPath);
	</script>
</title>
<selection>Subt_FontPath</selection>
<param>JukeboxPath%20browse</param>
<pos>45</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_FontFile);
	</script>
</title>
<selection>Subt_FontFile</selection>
<param></param>
<pos></pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_Color);
	</script>
</title>
<selection>Subt_Color</selection>
<param>white%20yellow</param>
<pos>60</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_ColorBg);
	</script>
</title>
<selection>Subt_ColorBg</selection>
<param>transparent%20black</param>
<pos>70</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_Size);
	</script>
</title>
<selection>Subt_Size</selection>
<param>14%2018%2020%2022%2024%2026</param>
<pos>35</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_Pos);
	</script>
</title>
<selection>Subt_Pos</selection>
<param>0%20-0.500%20-1%20-1.500%20-2%20-2.500%20-3</param>
<pos>35</pos>
</item>

</channel>
</rss>
EOF
}

MenuCfg()
{
# RSS to edit srjg.cfg

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
EOF

LoadCfg
SaveTmpCfg

cat <<EOF
  langpath = Jukebox_Path + "lang/" + Language;
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    Lang_Lang = getXMLText("cfg", "Lang");
    Lang_Jukebox_Path = getXMLText("cfg", "Jukebox_Path");
    Lang_Jukebox_Size = getXMLText("cfg", "Jukebox_Size");
    Lang_Movies_Path = getXMLText("cfg", "Movies_Path");
		Lang_Nfo_Path = getXMLText("cfg", "Nfo_Path");
		Lang_Poster_Path = getXMLText("cfg", "Poster_Path");
		Lang_Sheet_Path = getXMLText("cfg", "Sheet_Path");
    Lang_UnlockRM = getXMLText("cfg", "UnlockRM");
    Lang_SingleDb = getXMLText("cfg", "SingleDb");
    Lang_Movie_Filter = getXMLText("cfg", "Movie_Filter");
    Lang_Imdb = getXMLText("cfg", "Imdb");
		Lang_Dspl = getXMLText("cfg", "Dspl");
    Lang_Port = getXMLText("cfg", "Port");
    Lang_Version = getXMLText("cfg", "Version");
    Lang_Recent_Max = getXMLText("cfg", "Recent_Max");
    Lang_Yes = getXMLText("cfg", "yes");
    Lang_No = getXMLText("cfg", "no");
  }

  Version = readStringFromFile(Jukebox_Path + "Version");
  if ( Version == null ) print ("Version File not found");
</onEnter>

<mediaDisplay name="photoView" rowCount="12" columnCount="1" drawItemText="no" showHeader="no" showDefaultInfo="no" menuBorderColor="255:255:255" sideColorBottom="-1:-1:-1" sideColorTop="-1:-1:-1" itemAlignt="left" itemOffsetXPC="4" itemOffsetYPC="21" itemWidthPC="32" itemHeightPC="5" backgroundColor="-1:-1:-1" itemBackgroundColor="-1:-1:-1" sliding="no" itemGap="0" idleImageXPC="90" idleImageYPC="5" idleImageWidthPC="5" idleImageHeightPC="8" imageUnFocus="null" imageParentFocus="null" imageBorderPC="0" forceFocusOnItem="no" cornerRounding="yes" itemBorderColor="-1:-1:-1" focusBorderColor="-1:-1:-1" unFocusBorderColor="-1:-1:-1">
<idleImage> image/POPUP_LOADING_01.png </idleImage> 
<idleImage> image/POPUP_LOADING_02.png </idleImage> 
<idleImage> image/POPUP_LOADING_03.png </idleImage> 
<idleImage> image/POPUP_LOADING_04.png </idleImage> 
<idleImage> image/POPUP_LOADING_05.png </idleImage> 
<idleImage> image/POPUP_LOADING_06.png </idleImage> 
<idleImage> image/POPUP_LOADING_07.png </idleImage> 
<idleImage> image/POPUP_LOADING_08.png </idleImage> 

<!-- comment menu display -->
<image type="image/jpeg" redraw="no" offsetXPC="37" offsetYPC="23" widthPC="3" heightPC="4">
	<script>
		print(Jukebox_Path + "images/countries/" + Language + ".png");
	</script>
</image>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="40" offsetYPC="23" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Language);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="29" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Movies_Path);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="35" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Nfo_Path);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="41" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Poster_Path);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="47" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Sheet_Path);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="53" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( SingleDb == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="59" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Movie_Filter);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="65" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Jukebox_Size);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="71" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Recent_Max);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="77" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( Imdb == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="36" offsetYPC="89" widthPC="57" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		if ( UnlockRM == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<!-- info display -->
<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="59" offsetYPC="10" widthPC="37" heightPC="4" fontSize="16" lines="1" align="center">
	<script>
		print(Lang_Jukebox_Path);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="59" offsetYPC="14" widthPC="37" heightPC="4" fontSize="13" lines="1" align="center">
	<script>
		print(Jukebox_Path);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="65" offsetYPC="18" widthPC="23" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Lang_Port);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="75" offsetYPC="18" widthPC="10" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Port);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="65" offsetYPC="22" widthPC="10" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Lang_Version);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="75" offsetYPC="22" widthPC="10" heightPC="4" fontSize="16" lines="1" align="left">
	<script>
		print(Version);
	</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      mode=getItemInfo(indx, "selection");
      if ( mode == "Movie_Filter") {
        inputFilter=getInput("userName","doModal");
        if (inputFilter != NULL) {
          mode="UpdateCfg";
          YPos="Movie_Filter";
          SelParam=inputFilter;
					jumpToLink("SelectionEntered");
        }
      } else if ( mode == "NumberEdit" ) {
        TmpVal=doModalRss("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?NumberEdit@2000@13@67@"+Recent_Max+"@");
        if ( TmpVal &gt; 0 ) {
          Recent_Max = TmpVal;
          dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+Recent_Max+"@Recent_Max@");
        }
      } else {
        SelParam=getItemInfo(indx, "param");
        YPos=getItemInfo(indx, "pos");
        jumpToLink("SelectionEntered");
			}
      "false";
    }
  </script>
</onUserInput>

 
<itemDisplay>

<image type="image/png" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
 <script>
  if (getDrawingItemState() == "focus") print(Jukebox_Path + "images/focus_on.png");
  else print(Jukebox_Path + "images/focus_off.png");
 </script>
</image>

<text redraw="no" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="14" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>  

   <backgroundDisplay>
        <image type="image/jpeg" redraw="no" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
	     <script>
                 print(Jukebox_Path + "images/srjgMainMenu.jpg");
             </script>
        </image>
    </backgroundDisplay> 

</mediaDisplay>

<SelectionEntered>
    <link>
       <script>
           print("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?"+mode+"@"+SelParam+"@"+YPos);
       </script>
    </link>
</SelectionEntered>

<channel>
<title>Config menu</title>

<item>
<title>
	<script>
		print(Lang_Lang);
	</script>
</title>
<selection>Lang</selection>
<param>cz%20en%20es%20fr%20pl%20ro</param>
<pos>25</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Movies_Path);
	</script>
</title>
<selection>FBrowser</selection>
<param>Movies_Path</param>
<pos>0</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Nfo_Path);
	</script>
</title>
<selection>Nfo_Path</selection>
<param>MoviesPath%20SRJG%20browse</param>
<pos>27</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Poster_Path);
	</script>
</title>
<selection>Poster_Path</selection>
<param>MoviesPath%20SRJG%20browse</param>
<pos>33</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Sheet_Path);
	</script>
</title>
<selection>Sheet_Path</selection>
<param>MoviesPath%20SRJG%20browse</param>
<pos>40</pos>
</item>

<item>
<title>
	<script>
		print(Lang_SingleDb);
	</script>
</title>
<selection>SingleDb</selection>
<param>yes%20no</param>
<pos>43</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Movie_Filter);
	</script>
</title>
<selection>Movie_Filter</selection>
<param></param>
<pos></pos>
</item>

<item>
<title>
	<script>
		print(Lang_Jukebox_Size);
	</script>
</title>
<selection>Jukebox_Size</selection>
<param>2x6%203x8%20sheetwall</param>
<pos>43</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Recent_Max);
	</script>
</title>
<selection>NumberEdit</selection>
<param>Recent_Max</param>
<pos>50</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Imdb);
	</script>
</title>
<selection>ImdbCfgEdit</selection>
<param></param>
<pos></pos>
</item>

<item>
<title>
	<script>
		print(Lang_Dspl);
	</script>
</title>
<selection>DsplCfgEdit</selection>
<param></param>
<pos></pos>
</item>

<item>
<title>
	<script>
		print(Lang_UnlockRM);
	</script>
</title>
<selection>UnlockRM</selection>
<param>no%20yes</param>
<pos>75</pos>
</item>

</channel>
</rss>
EOF
}

FBrowser()
{
# File browser
# Original code from DMD RM Jukebox by Martini(CZ) from DMD team
#    Contact: w0m@seznam.cz, http://www.hddplayer.cz
# Modified and adapted to the srjg project

echo -e '
<?xml version='1.0' ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter> 
  Jukebox_Path="$Jukebox_Path";
  langpath = Jukebox_Path + "lang/$Language";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
		FBrowser_Title = getXMLText("FBrowser", "FBrowser_Title");
		FBrowser_Valid = getXMLText("FBrowser", "FBrowser_Valid");
  }
  dirCount=0;
  dir2File = "/tmp/srjg_Browser_dir.list";
  dirArray = null;
  Ch_Base = "/tmp/public/";
/*   Ch_Base = "/tmp/ramfs/volumes/"; */
  Ch_Sel = Ch_Base;
  executeScript("listDir");
  setFocusItemIndex(0);
  RedrawDisplay();
</onEnter>

<onExit>
  if ( "$CategoryTitle" != "Movies_Path" ) postMessage("return");
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
    <script>print(Jukebox_Path + "images/FBrowser_Bg.jpg");</script>
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=10 fontSize=14 backgroundColor=-1:-1:-1    foregroundColor=70:140:210>
  <script>print(FBrowser_Title);</script>
</text>

<image redraw="no" offsetXPC="10" offsetYPC="90.5" widthPC="9" heightPC="7.2">
  <script>print(Jukebox_Path + "images/play.png");</script>
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
		      New = Ch_Sel;
		    }
        print(New);
    </script>
</text>

<itemDisplay>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
  if (getDrawingItemState() == "focus") print(Jukebox_Path + "images/focus_on.png");
  else print(Jukebox_Path + "images/FBrowser_unfocus.png");
    </script>
  </image>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="25" widthPC="8" heightPC="50">
    <script>
					  Jukebox_Path +"images/folder.png";
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
		    Ch_Sel = getStringArrayAt(pathArray, curidx);
		    executeScript("listDir");
  
        setFocusItemIndex(0);
        RedrawDisplay();
        "true";

  } else if ( userInput == "video_play" ) {
		    curidx = getFocusItemIndex();
		    if (curidx != 0) {
		      New_Ch_Base = getStringArrayAt(pathArray, curidx);
		    } else {
		      New_Ch_Base = Ch_Sel;
		    }
        setEnv("New_Path",New_Ch_Base);
        New_Ch_Base=urlEncode(New_Ch_Base);
        dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+New_Ch_Base+"@$CategoryTitle");
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
    writeStringToFile(dir2File, Ch_Sel);
    dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?DirList");
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
          path = Ch_Sel + test + "/";
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
            <script>
				getStringArrayAt(titleArray , -1);
			</script>
        </displayTitle>
        <media:thumbnail>
            <script>
			url = Jukebox_Path + "folder.png";
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

UpdateCfg()
{
# Update the srjg.cfg

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

Cfg_Tag=$Jukebox_Size
Cfg_Par=$CategoryTitle

if ([ "$Cfg_Tag" = "Movies_Path" ] || [ "$Cfg_Tag" = "Nfo_Path" ] || [ "$Cfg_Tag" = "Sheet_Path" ] || [ "$Cfg_Tag" = "Poster_Path" ] || [ "$Cfg_Tag" = "Subt_FontPath" ] || [ "$Cfg_Tag" = "Subt_FontFile" ]) \
   && ([ "$Cfg_Par" != "SRJG" ] && [ "$Cfg_Par" != "MoviesPath" ] && [ "$Cfg_Par" != "JukeboxPath" ]) ; then
  sed -i "s:<$Cfg_Tag>.*</$Cfg_Tag>:<$Cfg_Tag>\"$Cfg_Par\"</$Cfg_Tag>:" /usr/local/etc/srjg.cfg
else
  sed -i "s:<$Cfg_Tag>.*</$Cfg_Tag>:<$Cfg_Tag>$Cfg_Par</$Cfg_Tag>:" /usr/local/etc/srjg.cfg
fi

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

ReplaceCd1byCd2()
{
# replace string

Cd2=`echo "$CategoryTitle" | sed 's:\(.*\)cd1:\1cd2:'`
echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
setEnv("MovieCd2","$Cd2");
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
<channel></channel></rss>
EOF
exit 0
}

srtList()
{
# Find srt files

ls "${CategoryTitle}"*.srt >/tmp/srjg_srt_dir.list 2>/dev/null

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
<channel></channel></rss>
EOF
exit 0
}

FontList()
{
# Find fonts files

if [ "${Subt_FontPath}" = "JukeboxPath" ]; then
  FontPath="${Jukebox_Path}font/"
else
  FontPath="${Subt_FontPath}"
fi

cd "${FontPath}"
ls *.ttf >"/tmp/srjg_font_dir.list" 2>/dev/null

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
<channel></channel></rss>
EOF
exit 0
}

SubTitleGen()
{
# convert srt -> xml

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

Fxml="/tmp/srjg_subtitle.xml"
SubTGen=""
i=0
j=0

rm ${Fxml} 2>/dev/null

if [ -z `awk 2>&1 | grep 1.1.3` ]; then
  awkBin=awk
else awkBin=/usr/local/bin/package/awk; fi

${awkBin} '
$0 ~ /\015$/ { sub( "\015$", "" ) }
/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] -->/ { 
  B1=substr($0, 1, 2); B2=substr($0, 4, 2); B3=substr($0, 7, 2); B4=substr($0, 10, 3);
  E1=substr($0, 18, 2); E2=substr($0, 21, 2); E3=substr($0, 24, 2); E4=substr($0, 27, 3);
  Tbeg = 3600 * B1 + 60 * B2 + B3 + B4 / 1000 
  Tend = 3600 * E1 + 60 * E2 + E3 + E4 / 1000  
  if (i==3) { print Ligne[1]"\n"Ligne[2] } else {if (i==2) { print "\n"Ligne[1] }}
  i=1 ; Ligne[1]=""; Ligne[2]=""
  printf("%i\n%i\n", Tbeg,Tend)
}
$0 !~ /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] -->/ && ! /^[0-9][0-9]*$/ && ! /^$/ {
  Ligne[i]=$0
  if ( i == 1 ) { i=2 } else { i=3 }
}

END {
  if (i==3) { print Ligne[1]"\n"Ligne[2] } else {if (i==2) { print "\n"Ligne[1] }}
}
' "${CategoryTitle}" >"${Fxml}"

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

PlayMovie()
{
# Screen to play movie with subtitle and Time seek
# Idea from Serge A. Timchenko
# http://code.google.com/media-translate/
# Credit to vb6rocod for subtitle add-on
# http://code.google.com/p/hdforall
# Modified and adapted to the srjg project

echo -e '
<?xml version='1.0' encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
EOF

LoadCfg
SaveTmpCfg

if [ "${Subt_FontPath}" = "JukeboxPath" ]; then
  FontPath="${Jukebox_Path}font/"
else
  FontPath="${Subt_FontPath}"
fi

FontFile="${FontPath}${Subt_FontFile}"

cat <<EOF
  SubTitle="${Jukebox_Size}";
  pause = 0;

  if ( "$Subt_ColorBg" == "transparent" ) transp = "-1:-1:-1";
  else transp = "0:0:0";
  if ( "$Subt_Color" == "white" ) fontcol = "255:255:255";
  else fontcol = "255:255:100";
  fontsize = "${Subt_Size}";
  fontoffset = "${Subt_Pos}";
  fontname="${FontFile}";

if (fontsize &lt; 22)
{
  wh=7;
  mt=2;
}
else
{
	if (fontsize &gt;=22 &amp;&amp; fontsize &lt; 26)
		{
			wh=8;
			mt=2;
		}	
		else
		{
			wh=9;
			mt=2.1;
		}
}
  
  yy=0;
  ref=0;
  show_time = 0;

  nTotSubs = 0;
  tline1="";
  tline2="";
  if ( SubTitle == "true" ) {
    ASubt= readStringFromFile("/tmp/srjg_subtitle.xml");
    if (ASubt != null)
    {
      print("success");
      i=0;
      EASubt="Start";
      while ( EASubt != null )
      {
        EASubt = getStringArrayAt(ASubt,i);
        i += 4;
      }
      nTotSubs=(i-4)/4;
      ntime_start = 0;
      ntime_end = 0;
      ntime_next_start=0;
      tline1 = "Wait...";
      tline2 = "";
      last_tline1="";
      last_tline2="";
      nCurSub=0;
	  }
  }

  cancelIdle();
  playItemURL("${CategoryTitle}", 0, "mediaDisplay", "previewWindow");
    
  stream_elapsed = "Wait...";
  check_counter = 15;
  refresh_time = 100;
  setRefreshTime(50);
  cancelIdle();
  redrawDisplay();
</onEnter>

<onExit>
	playItemURL(-1, 1);
	setRefreshTime(-1);
  /* Save settings before exit */
  if ( "${Subt_Pos}" != fontoffset ) {
    UE_Subt_Pos=urlEncode(fontoffset);
    dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+UE_Subt_Pos+"@Subt_Pos@");
    Subt_Pos=fontoffset;
  }
EOF

SaveTmpCfg

cat <<EOF
</onExit>

<onRefresh>
	stream_progress  = getPlaybackStatus();
	buffer_progress  = getCachedStreamDataSize(0, 262144);
	buffer           = getStringArrayAt(buffer_progress, 0);
	play_elapsed     = getStringArrayAt(stream_progress, 0);
	play_total       = getStringArrayAt(stream_progress, 1);
	play_rest        = play_total - play_elapsed;
	play_status      = getStringArrayAt(stream_progress, 3);
	

	if (play_elapsed != 0)
	{
    arg_time = play_elapsed;
		x = Integer(arg_time / 60);
		h = Integer(arg_time / 3600);
		s = arg_time - (x * 60);
		m = x - (h * 60);
		if(h &lt; 10) 
			ret_string = "0" + sprintf("%s:", h);
		else
			ret_string = sprintf("%s:", h);
		if(m &lt; 10)  ret_string += "0";
		ret_string += sprintf("%s:", m);
		if(s &lt; 10)  ret_string += "0";
		ret_string += sprintf("%s", s);
    stream_elapsed = ret_string;
    
		  arg_time = play_total;
  		x = Integer(arg_time / 60);
  		h = Integer(arg_time / 3600);
  		s = arg_time - (x * 60);
  		m = x - (h * 60);
  		if(h &lt; 10) 
  			ret_string = "0" + sprintf("%s:", h);
  		else
  			ret_string = sprintf("%s:", h);
  		if(m &lt; 10)  ret_string += "0";
  		ret_string += sprintf("%s:", m);
  		if(s &lt; 10)  ret_string += "0";
  		ret_string += sprintf("%s", s);
		  stream_total = ret_string;
    xx = Integer(play_elapsed / 90);
    yy = play_elapsed - (xx * 90);
    if (show_time == 1)
        stream_elapsed1 = stream_elapsed + " / " + stream_total;
    if (yy == 0 &amp;&amp; ref == 0)
    {
     ref = 1;
    } 
		if (play_total &gt; 0 &amp;&amp; play_total &lt; 1000000 &amp;&amp; nTotSubs &gt; 2 &amp;&amp; (nCurSub/4) &lt;= nTotSubs)
		{
	    if (yy !=0) ref = 0;
      ntime_start = getStringArrayAt(ASubt,nCurSub);
      ntime_end = getStringArrayAt(ASubt,Add(nCurSub, 1));
      ntime_next_start = getStringArrayAt(ASubt,Add(nCurSub, 4));
		  if (play_elapsed &gt;= ntime_start &amp;&amp; play_elapsed &lt; ntime_end)
		  {
		    tline1 = getStringArrayAt(ASubt,Add(nCurSub, 2));
        tline2 = getStringArrayAt(ASubt,Add(nCurSub, 3));
		    updatePlaybackProgress(buffer_progress, "mediaDisplay", "infoDisplay");
		  }	   
      else if (play_elapsed &gt;= ntime_end)
      {
        while (1)
        {
        nCurSub += 4 ;
        if ( (nCurSub/4) &gt; nTotSubs)
          {
           tline1="";
           tline2="";
           break;
          }
           tt1 = getStringArrayAt(ASubt,nCurSub);
           if (tt1 &gt;= play_elapsed) break;             
        }
        if (ntime_next_start == ntime_end)
          updatePlaybackProgress(buffer_progress, "mediaDisplay", "infoDisplay");
      }
      else if (show_time == 1)
         updatePlaybackProgress(buffer_progress, "mediaDisplay", "infoDisplay");
		}
    else
    {
    tline1="";
    }
	}
	else
	{
	updatePlaybackProgress(buffer_progress, "mediaDisplay", "infoDisplay");
	}

</onRefresh>

<mediaDisplay name="threePartsView" 
  showDefaultInfo="no" 
  showHeader="no" 
  sideLeftWidthPC="0" 
  sideRightWidthPC="0" 
  backgroundColor="0:0:0"
  idleImageXPC="5" idleImageYPC="5" idleImageWidthPC="8" idleImageHeightPC="10"
  >
        <idleImage>image/POPUP_LOADING_01.png</idleImage>
        <idleImage>image/POPUP_LOADING_02.png</idleImage>
        <idleImage>image/POPUP_LOADING_03.png</idleImage>
        <idleImage>image/POPUP_LOADING_04.png</idleImage>
        <idleImage>image/POPUP_LOADING_05.png</idleImage>
        <idleImage>image/POPUP_LOADING_06.png</idleImage>
        <idleImage>image/POPUP_LOADING_07.png</idleImage>
        <idleImage>image/POPUP_LOADING_08.png</idleImage>

  <previewWindow windowColor="0:0:0" offsetXPC="0" widthPC="100" offsetYPC="0" heightPC="100">

  </previewWindow>
<infoDisplay offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">

    		<text lines="1" useBackgroundSurface="yes" align="left" redraw="yes" offsetXPC="2.5" offsetYPC="2.5" widthPC="50" heightPC="6" fontSize="20" backgroundColor="-1:-1:-1" foregroundColor="255:255:255">
EOF

[ -e "${FontFile}" ] && echo '<fontFile><script>fontname;</script></fontFile>'

cat <<EOF
  			<script>stream_elapsed1;</script>
  		</text>

    		<text align="center" redraw="yes" offsetXPC="0" useBackgroundSurface="yes">
  			<script>tline1;</script>
EOF

[ -e "${FontFile}" ] && echo '<fontFile><script>fontname;</script></fontFile>'

cat <<EOF
  			<offsetYPC>
  			<script>
  			99 + fontoffset - mt*wh;
  			</script>
  			</offsetYPC>
  			<fontSize>
  			<script>
  			4 + fontsize;
  			</script>
  			</fontSize>
  			<foregroundColor>
  			<script>
           fontcol;
  			</script>
  			</foregroundColor>
  			<backgroundColor>
  			<script>
        transp;
  			</script>
  			</backgroundColor>
  			<widthPC>
  			<script>
  			if (nTotSubs &gt; 2)
  			   100;
  			else
  			   1;
  			</script> 
  			</widthPC>
  			<heightPC>
  			<script>
  			if (nTotSubs &gt; 2 )
  			  {
            wh;
          }
  			else
  			   1; 
  			</script>
  			</heightPC>
  		</text>
    		<text align="center" redraw="yes" offsetXPC="0" useBackgroundSurface="yes">
  			<script>tline2;</script>
EOF

[ -e "${FontFile}" ] && echo '<fontFile><script>fontname;</script></fontFile>'

cat <<EOF
  			<offsetYPC>
  			<script>
  			 98 + fontoffset - wh; 			
  			</script>
  			</offsetYPC>
  			<fontSize>
  			<script>
  			4 + fontsize;
  			</script>
  			</fontSize>
  			<foregroundColor>
  			<script>
  			fontcol;
  			</script>
  			</foregroundColor>
  			<backgroundColor>
  			<script>
        transp;
  			</script>
  			</backgroundColor>
  			<widthPC>
  			<script>
  			if (nTotSubs &gt; 2)
  			   100;
  			else
  			   1;
  			</script> 
  			</widthPC>
  			<heightPC>
  			<script>
  			if (nTotSubs &gt; 2 )
           wh;
  			else
  			   1; 
  			</script>
  			</heightPC>
  		</text>
</infoDisplay>
<onUserInput>
input = currentUserInput();
print("**** input=",input);
ret = "false";
if (input == "display" || input == "DISPLAY")
{
redrawDisplay("yes");
}
else if ((input == "enter" || input == "ENTR") &amp;&amp; pause == 1)
{
postMessage("video_play");
pause = 0;
ret = "true";
}
else if ((input == "enter" || input == "ENTR") &amp;&amp; pause == 0)
{
postMessage("video_pause");
pause = 1;
ret = "true";
}
else if (input == "video_completed" || input == "video_stop")
{
playItemURL(-1, 1);
postMessage("return");
}
else if (input == "zero" || input == "0")
{ 
  show_time = 1 - show_time;
  stream_elapsed1 = "";
  ret = "true";
}
else if (input == "right" || input == "left" || input == "R" || input == "L")
{
	status = getPlaybackStatus();
	playStatus = getStringArrayAt(status, 3);
	if (playStatus == "2")
	{
		setEnv("videoStatus", status);
		playItemURL(-1, 2);
		print("LOUIS - link to seekpop");
		timePoint = doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?SeekPopup");
		if (timePoint != -1)
		{
			playAtTime(timePoint);
		}
		ret = "true";
	}
}
else if (input == "up" || input == "U")
{
    fontoffset = fontoffset - "0.5" ;
    ret = "true";
    }
      else if (input == "down" || input == "D")
    {
      fontoffset = "0.5" + fontoffset ;
      ret = "true";
}
else if ( input == "edit" ) {
  dlok = doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?SubtPopup@");
  /* reload config */
  Config = "/usr/local/etc/srjg.cfg";
  Config_ok = loadXMLFile(Config);
  if (Config_ok == null) print("Load Config fail ", Config);
  else {
		Jukebox_Path = getXMLText("Config", "Jukebox_Path");
    Subt_Color = getXMLText("Config", "Subt_Color");
    Subt_ColorBg = getXMLText("Config", "Subt_ColorBg");
    Subt_Size = getXMLText("Config", "Subt_Size");
  }
  if ( Subt_ColorBg == "transparent" ) transp = "-1:-1:-1";
  else transp = "0:0:0";
  if ( Subt_Color == "white" ) fontcol = "255:255:255";
  else fontcol = "255:255:100";
  fontsize = Subt_Size;
  AFile=readStringFromFile("/tmp/srjg_fontname");
  fontname=getStringArrayAt(AFile,0);

  if (fontsize &lt; 22) {
    wh=7;
    mt=2;
  } else {
	  if (fontsize &gt;=22 &amp;&amp; fontsize &lt; 26) {
			wh=8;
			mt=2;
		} else {
			wh=9;
			mt=2.1;
    }
  }
  ret = "true";
}
	ret;
</onUserInput>
	
</mediaDisplay>


<channel>
	<title>video stream player</title>
</channel>

</rss>
EOF
}


DirList()
{
# List HDD or Usb devices

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

folder=`sed -n '1p' /tmp/srjg_Browser_dir.list`

dirname=${folder%/*}
prevdir=${dirname%/*}

echo $prevdir"/" > /tmp/srjg_Browser_dir.list

cd "$folder"
echo */ " " | sed "s/\/ /\n/g"  >> /tmp/srjg_Browser_dir.list

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

SubMenucfg()
{
# auto choice menu to edit cfg

Item_nb=0
for SelParam in $CategoryTitle
do
  let Item_nb+=1
done

XPos=$Parm_4
[ $XPos = 0 ] && XPos=10
YPos=$Jukebox_Size

echo -e '
<?xml version="1.0"   encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
</onEnter>

<mediaDisplay name="photoView" rowCount="$Item_nb" columnCount="1" drawItemText="no" showHeader="no" showDefaultInfo="no" menuBorderColor="255:255:255" sideColorBottom="-1:-1:-1" sideColorTop="-1:-1:-1" itemAlignt="left" itemOffsetXPC="$XPos" itemOffsetYPC="$YPos" itemWidthPC="20" itemHeightPC="7.2" backgroundColor="-1:-1:-1" itemBackgroundColor="-1:-1:-1" sliding="no" itemGap="0" idleImageXPC="90" idleImageYPC="5" idleImageWidthPC="5" idleImageHeightPC="8" imageUnFocus="null" imageParentFocus="null" imageBorderPC="0" forceFocusOnItem="no" cornerRounding="yes" itemBorderColor="-1:-1:-1" focusBorderColor="-1:-1:-1" unFocusBorderColor="-1:-1:-1">
<idleImage> image/POPUP_LOADING_01.png </idleImage>
<idleImage> image/POPUP_LOADING_02.png </idleImage>
<idleImage> image/POPUP_LOADING_03.png </idleImage>
<idleImage> image/POPUP_LOADING_04.png </idleImage>
<idleImage> image/POPUP_LOADING_05.png </idleImage>
<idleImage> image/POPUP_LOADING_06.png </idleImage>
<idleImage> image/POPUP_LOADING_07.png </idleImage>
<idleImage> image/POPUP_LOADING_08.png </idleImage>
<itemDisplay>

<image offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
 <script>
  if (getDrawingItemState() == "focus") print("${Jukebox_Path}images/focus_on.png");
  else print("${Jukebox_Path}images/focus_off.png");
 </script>
</image>

<text redraw="no" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="16" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>  

<onUserInput>

  userInput = currentUserInput();

  if (userInput == "right") {
    "true";
  } else if (userInput == "enter") {
    indx=getFocusItemIndex();
    action=getItemInfo(indx, "action");
    selparam=getItemInfo(indx, "selparam");
    param=getItemInfo(indx, "param");
    if ( param == "Subt_FontPath" &amp;&amp; selparam == "JukeboxPath" ) setEnv("New_Path","JukeboxPath");
    jumpToLink("SelectionEntered");
    if (action != "FBrowser") postMessage("return");
    "false";
  }

</onUserInput>
</mediaDisplay>

<SelectionEntered>
    <link>
       <script>
           print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?"+action+"@"+selparam+"@"+param);
       </script>
    </link>
</SelectionEntered>

<channel>
<title>Updating Cfg</title>
EOF

Item_nb=0
for SelParam in $CategoryTitle
do
  case ${SelParam} in
    "yes") Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
    "no")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
    "top")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
    "bottom")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
    "white")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
    "black")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
		"yellow")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
		"transparent")  Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=UpdateCfg; Param=$mode;;
    "browse") Item_dspl=`sed "/<${SelParam}>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=FBrowser; SelParam=$mode;;
    *)     Item_dspl=$SelParam; Action=UpdateCfg; Param=$mode;;
  esac
cat <<EOF
<item>
<title>$Item_dspl</title>
<action>$Action</action>
<selparam>$SelParam</selparam>
<param>$Param</param>
</item>
EOF
done

echo '</channel></rss>' # to close the RSS
}

ImdbSheetDspl()
{
# fullscreen display demo Imdb sheet

echo -e '
<?xml version="1.0"?>
<rss version="2.0" xmlns:media="http://purl.org/dc/elements/1.1/" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
  redrawDisplay();
</onEnter>

<mediaDisplay name=photoView showHeader=no showDefaultInfo=no drawItemBorder=no viewAreaXPC=0 viewAreaYPC=0 viewAreaWidthPC=100 viewAreaHeightPC=100 itemOffsetXPC=0 itemOffsetYPC=0 sideTopHeightPC=0 sideBottomHeightPC=0 bottomYPC=100 backgroundColor=0:0:0 >
<idleImage> image/POPUP_LOADING_01.png </idleImage> 
<idleImage> image/POPUP_LOADING_02.png </idleImage> 
<idleImage> image/POPUP_LOADING_03.png </idleImage> 
<idleImage> image/POPUP_LOADING_04.png </idleImage> 
<idleImage> image/POPUP_LOADING_05.png </idleImage> 
<idleImage> image/POPUP_LOADING_06.png </idleImage> 
<idleImage> image/POPUP_LOADING_07.png </idleImage> 
<idleImage> image/POPUP_LOADING_08.png </idleImage> 

<backgroundDisplay>

<text redraw="no" align="left" offsetXPC="25" offsetYPC="50" widthPC="100" heightPC="6" fontSize="20" backgroundColor="-1:-1:-1" foregroundColor="255:255:255">
  <script>print("Press 1 to refresh...");</script>
</text>

<script>
	LnParam="name=avatar&amp;mode=sheet&amp;font=$Imdb_Font&amp;lang=$Imdb_Lang&amp;source=$Imdb_Source";
  if ( "$Imdb_Backdrop" != "no" ) LnParam=LnParam+"&amp;backdrop=y";
  if ( "$Imdb_SPost" != "no" ) LnParam=LnParam+"&amp;post=y";
  if ( "$Imdb_SBox" != "no" ) LnParam=LnParam+"&amp;box=$Imdb_SBox";
	if ( "$Imdb_Tagline" != "no" ) LnParam=LnParam+"&amp;tagline=y";
	if ( "$Imdb_Time" != "no" ) LnParam=LnParam+"&amp;time=$Imdb_Time";
  if ( "$Imdb_Genres" != "no" ) LnParam=LnParam+"&amp;genres=$Imdb_Genres";
  ImdbLink = "http://playon.unixstorm.org/IMDB/movie_beta.php?" + LnParam;
</script>

<image offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=100><script> print(ImdbLink); </script></image>

</backgroundDisplay>

<onUserInput>
	userInput = currentUserInput();
  redrawDisplay();
</onUserInput>
</mediaDisplay>

<channel>
<title>SheetView Imdb</title>

</channel>
</rss>
EOF
}

ImdbCfgEdit()
{
# Imdb Config editor

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
EOF

LoadCfg
SaveTmpCfg

cat <<EOF
  /* Translated values */ 
  langpath = Jukebox_Path + "lang/" + Language;
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    Lang_Imdb = getXMLText("cfg", "Imdb");
    Lang_Yes = getXMLText("cfg", "yes");
    Lang_No = getXMLText("cfg", "no");
    Lang_Use=getXMLText("Imdb", "Imdb_Use");
    Lang_Lang=getXMLText("Imdb", "Imdb_Lang");
    Lang_Source=getXMLText("Imdb", "Imdb_Source");
    Lang_Poster=getXMLText("Imdb", "Imdb_Poster");
    Lang_PBox=getXMLText("Imdb", "Imdb_PBox");
    Lang_PPost=getXMLText("Imdb", "Imdb_PPost");
    Lang_Sheet=getXMLText("Imdb", "Imdb_Sheet");
    Lang_SBox=getXMLText("Imdb", "Imdb_SBox");
    Lang_SPost=getXMLText("Imdb", "Imdb_SPost");
    Lang_Backdrop=getXMLText("Imdb", "Imdb_Backdrop");
    Lang_Font=getXMLText("Imdb", "Imdb_Font");
    Lang_Genres=getXMLText("Imdb", "Imdb_Genres");
    Lang_Tagline=getXMLText("Imdb", "Imdb_Tagline");
    Lang_Time=getXMLText("Imdb", "Imdb_Time");
    Lang_Info=getXMLText("Imdb", "Imdb_Info");
    Lang_MaxDl=getXMLText("Imdb", "Imdb_MaxDl");
  }
</onEnter>

<mediaDisplay name="photoView" rowCount="16" columnCount="1" drawItemText="no" showHeader="no" showDefaultInfo="no" menuBorderColor="255:255:255" sideColorBottom="-1:-1:-1" sideColorTop="-1:-1:-1" itemAlignt="left" itemOffsetXPC="4" itemOffsetYPC="4" itemWidthPC="30" itemHeightPC="4" backgroundColor="-1:-1:-1" itemBackgroundColor="-1:-1:-1" sliding="no" itemGap="0" idleImageXPC="90" idleImageYPC="5" idleImageWidthPC="5" idleImageHeightPC="8" imageUnFocus="null" imageParentFocus="null" imageBorderPC="0" forceFocusOnItem="no" cornerRounding="yes" itemBorderColor="-1:-1:-1" focusBorderColor="-1:-1:-1" unFocusBorderColor="-1:-1:-1">
<idleImage> image/POPUP_LOADING_01.png </idleImage> 
<idleImage> image/POPUP_LOADING_02.png </idleImage> 
<idleImage> image/POPUP_LOADING_03.png </idleImage> 
<idleImage> image/POPUP_LOADING_04.png </idleImage> 
<idleImage> image/POPUP_LOADING_05.png </idleImage> 
<idleImage> image/POPUP_LOADING_06.png </idleImage> 
<idleImage> image/POPUP_LOADING_07.png </idleImage> 
<idleImage> image/POPUP_LOADING_08.png </idleImage> 

<!-- covert display -->
<image type="image/jpeg" offsetXPC="68" offsetYPC="4" widthPC="14" heightPC="40">
  <script>
    if ( Imdb == "no" || Imdb_Poster == "no" ) "${Jukebox_Path}images/nofolder.jpg";
    else {
	    LnParam="name=avatar&amp;mode=poster&amp;source="+Imdb_Source;
      if ( Imdb_PBox != "no" ) LnParam=LnParam+"&amp;box="+Imdb_PBox;
	    if ( Imdb_PPost != "no" ) LnParam=LnParam+"&amp;post=y";
      "http://playon.unixstorm.org/IMDB/movie_beta.php?" + LnParam;
    }
  </script>
</image>

<script>

</script>
	
<image offsetXPC="47" offsetYPC="46" widthPC="65" heightPC="50">
  <script>
    if ( Imdb == "no" || Imdb_Sheet == "no" ) "${Jukebox_Path}images/NoMovieinfo.jpg";
    else {
	    LnParam="name=avatar&amp;mode=sheet&amp;font="+Imdb_Font+"&amp;lang="+Imdb_Lang+"&amp;source="+Imdb_Source;
      if ( Imdb_Backdrop != "no" ) LnParam=LnParam+"&amp;backdrop=y";
      if ( Imdb_SPost != "no" ) LnParam=LnParam+"&amp;post=y";
      if ( Imdb_SBox != "no" ) LnParam=LnParam+"&amp;box="+Imdb_SBox;
	    if ( Imdb_Tagline != "no" ) LnParam=LnParam+"&amp;tagline=y";
	    if ( Imdb_Time != "no" ) LnParam=LnParam+"&amp;time="+Imdb_Time;
      if ( Imdb_Genres != "no" ) LnParam=LnParam+"&amp;genres="+Imdb_Genres;
      "http://playon.unixstorm.org/IMDB/movie_beta.php?" + LnParam;
    }
  </script>
</image>


<!-- comment menu display -->
<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="5.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="10.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		print(Imdb_Lang);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="15.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		print(Imdb_Source);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="20.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Poster == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="25.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_PBox == "no" ) print( Lang_No );
    else print( Imdb_PBox );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="30.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_PPost == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="35.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Sheet == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="40.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_SBox == "no" ) print( Lang_No );
    else print( Imdb_SBox );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="45.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_SPost == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="50.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Backdrop == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="55.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		print(Imdb_Font);
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="60.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Genres == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="65.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Tagline == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="70.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Time == "no" ) print( Lang_No );
    else print( Imdb_Time );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="75.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		if ( Imdb_Info == "yes" ) print( Lang_Yes );
    else print( Lang_No );
	</script>
</text>

<text redraw="no" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="34" offsetYPC="80.2" widthPC="57" heightPC="4" fontSize="14" lines="1" align="left">
	<script>
		print( Imdb_MaxDl );
	</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      mode=getItemInfo(indx, "selection");
      SelParam=getItemInfo(indx, "param");
      YPos=getItemInfo(indx, "pos");
      if ( mode == "NumberEdit" ) {
        TmpVal=doModalRss("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?NumberEdit@10@13@67@"+Imdb_MaxDl+"@");
        if ( TmpVal &gt; 0 ) {
          Imdb_MaxDl = TmpVal;
          dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+Imdb_MaxDl+"@Imdb_MaxDl@");
        }
      } else jumpToLink("SelectionEntered");
      "false";
    }	else if (userInput == "one") {
		  mode="ImdbSheetDspl";
			jumpToLink("SelectionEntered");
			"false";
    }	else if (userInput == "two") {
      redrawDisplay();
			"false";
    }
  </script>
</onUserInput>

 
<itemDisplay>

<image type="image/png" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
 <script>
  if (getDrawingItemState() == "focus")
  {
      print(Jukebox_Path + "images/focus_on.png");
  }
 else
  {
      print(Jukebox_Path + "images/focus_off.png");
  }
 </script>
</image>

<text redraw="no" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="13" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>  

  <backgroundDisplay>
    <image type="image/jpeg" redraw="no" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
      <script>
        print(Jukebox_Path + "images/srjgMainMenu.jpg");
      </script>
    </image>
  </backgroundDisplay> 
</mediaDisplay>

<SelectionEntered>
    <link>
       <script>
           print("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?"+mode+"@"+SelParam+"@"+YPos);
       </script>
    </link>
</SelectionEntered>

<channel>
<title>Imdb Config menu</title>

<item>
<title>
	<script>
		print(Lang_Use);
	</script>
</title>
<selection>Imdb</selection>
<param>yes%20no</param>
<pos>4</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Lang);
	</script>
</title>
<selection>Imdb_Lang</selection>
<param>en%20fr</param>
<pos>8</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Source);
	</script>
</title>
<selection>Imdb_Source</selection>
<param>de_filmstarts%20en_imdb%20en_screenrush%20en_tmdb%20es_sensacine%20fr_allocine%20tr_beyazperde</param>
<pos>8</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Poster);
	</script>
</title>
<selection>Imdb_Poster</selection>
<param>yes%20no</param>
<pos>10</pos>
</item>

<item>
<title>
	<script>
		print(Lang_PBox);
	</script>
</title>
<selection>Imdb_PBox</selection>
<param>no%20bdrip%20bluray%20dtheater%20dvd%20generic%20hddvd%20hdtv%20itunes</param>
<pos>21</pos>
</item>

<item>
<title>
	<script>
		print(Lang_PPost);
	</script>
</title>
<selection>Imdb_PPost</selection>
<param>yes%20no</param>
<pos>25</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Sheet);
	</script>
</title>
<selection>Imdb_Sheet</selection>
<param>yes%20no</param>
<pos>30</pos>
</item>

<item>
<title>
	<script>
		print(Lang_SBox);
	</script>
</title>
<selection>Imdb_SBox</selection>
<param>no%20bdrip%20bluray%20dtheater%20dvd%20generic%20hddvd%20hdtv%20itunes</param>
<pos>21</pos>
</item>

<item>
<title>
	<script>
		print(Lang_SPost);
	</script>
</title>
<selection>Imdb_SPost</selection>
<param>yes%20no</param>
<pos>40</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Backdrop);
	</script>
</title>
<selection>Imdb_Backdrop</selection>
<param>yes%20no</param>
<pos>47</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Font);
	</script>
</title>
<selection>Imdb_Font</selection>
<param>arial%20bookman%20comic%20tahoma%20times%20verdana</param>
<pos>43</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Genres);
	</script>
</title>
<selection>Imdb_Genres</selection>
<param>yes%20no</param>
<pos>57</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Tagline);
	</script>
</title>
<selection>Imdb_Tagline</selection>
<param>yes%20no</param>
<pos>65</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Time);
	</script>
</title>
<selection>Imdb_Time</selection>
<param>no%20real%20hours</param>
<pos>70</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Info);
	</script>
</title>
<selection>Imdb_Info</selection>
<param>yes%20no</param>
<pos>75</pos>
</item>

<item>
<title>
	<script>
		print(Lang_MaxDl);
	</script>
</title>
<selection>NumberEdit</selection>
<param>Imdb_MaxDl</param>
<pos>0</pos>
</item>

</channel>
</rss>
EOF
}

SubMenuEdit()
{
# auto choice menu to confirm Edit

Item_nb=0
for SelParam in $CategoryTitle
do
  let Item_nb+=1
done

YPos=$Jukebox_Size

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
</onEnter>

<onExit>
  postMessage("return");
</onExit>

<script>
  langpath = "${Jukebox_Path}lang/${Language}";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    lang_ValPoster = getXMLText("MEdit", "ValPoster");
    Lang_ValSheet = getXMLText("MEdit", "ValSheet");
    Lang_ValNfo = getXMLText("MEdit", "ValNfo");
		Lang_ValMovie = getXMLText("MEdit", "ValMovie");
  }
</script>

<mediaDisplay name="photoView" rowCount="$Item_nb" columnCount="1" drawItemText="no" showHeader="no" showDefaultInfo="no" menuBorderColor="255:255:255" sideColorBottom="-1:-1:-1" sideColorTop="-1:-1:-1" itemAlignt="left" itemOffsetXPC="38" itemOffsetYPC="$YPos" itemWidthPC="20" itemHeightPC="7.2" backgroundColor="-1:-1:-1" itemBackgroundColor="-1:-1:-1" sliding="no" itemGap="0" idleImageXPC="90" idleImageYPC="5" idleImageWidthPC="5" idleImageHeightPC="8" imageUnFocus="null" imageParentFocus="null" imageBorderPC="0" forceFocusOnItem="no" cornerRounding="yes" itemBorderColor="-1:-1:-1" focusBorderColor="-1:-1:-1" unFocusBorderColor="-1:-1:-1">
<idleImage> image/POPUP_LOADING_01.png </idleImage>
<idleImage> image/POPUP_LOADING_02.png </idleImage>
<idleImage> image/POPUP_LOADING_03.png </idleImage>
<idleImage> image/POPUP_LOADING_04.png </idleImage>
<idleImage> image/POPUP_LOADING_05.png </idleImage>
<idleImage> image/POPUP_LOADING_06.png </idleImage>
<idleImage> image/POPUP_LOADING_07.png </idleImage>
<idleImage> image/POPUP_LOADING_08.png </idleImage>

<text redraw="no" lines=4 offsetXPC="31" offsetYPC="31" widthPC="37" heightPC="23" backgroundColor="0:0:0" foregroundColor="200:200:200" fontSize="16" align="center" >
 <script>
    if ( "$mode" == "EM_Poster" ) print(lang_ValPoster);
    else if ( "$mode" == "EM_Sheet" ) print(Lang_ValSheet);
    else if ( "$mode" == "EM_Nfo" ) print(Lang_ValNfo);
    else print(Lang_ValMovie);
 </script>
</text>

<itemDisplay>
<image offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
 <script>
  if (getDrawingItemState() == "focus")
  {
      print("${Jukebox_Path}images/focus_on.png");
  }
 else
  {
      print("${Jukebox_Path}images/focus_off.png");
  }
 </script>
</image>

<text redraw="no" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="16" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>  

<onUserInput>

  userInput = currentUserInput();

  if (userInput == "right") {
    "true";
  } else if (userInput == "enter") {
    indx=getFocusItemIndex();
    action=getItemInfo(indx, "action");
    if ( action != "Nothing" ) jumpToLink("SelectionEntered");
    postMessage("return");
    "false";
  }

</onUserInput>
</mediaDisplay>

<SelectionEntered>
    <link>
       <script>
           print("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?"+action+"@$Parm_4@$mode");
       </script>
    </link>
</SelectionEntered>

<channel>
<title>Updating Cfg</title>
EOF

Item_nb=0
for SelParam in $CategoryTitle
do
  case ${SelParam} in
    "yes") Item_dspl=`sed "/<yes>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=DelMedia;;
    "no")  Item_dspl=`sed "/<no>/!d;s:.*>\(.*\)<.*:\1:" "${Jukebox_Path}lang/${Language}"`; Action=Nothing;;
    *)     Item_dspl=$SelParam; Action=DelMedia;;
  esac
cat <<EOF
<item>
<title>$Item_dspl</title>
<action>$Action</action>
</item>
EOF
done

echo '</channel></rss>' # to close the RSS
}

DelMedia()
{
# Remove Nfo, Poster, Sheet or/and Movie

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
  postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

# extract info 
MInfo="`${Sqlite} -separator ''  ${Database}  "SELECT path,file,ext FROM t1 WHERE Movie_ID like '$Search'" | grep "[!-~]";`"

MPath=`echo $MInfo |sed '/<path>/!d;s:.*>\(.*\)</path.*:\1:'`
MFile=`echo $MInfo |sed '/<file>/!d;s:.*>\(.*\)</file.*:\1:'`
MExt=`echo $MInfo |sed '/<ext>/!d;s:.*>\(.*\)</ext.*:\1:'`

if [ "${Poster_Path}" = "MoviesPath" ]; then PPath="${Movies_Path}";
elif [ "${Poster_Path}" = "SRJG" ]; then PPath="${Movies_Path}SRJG/ImgNfo";
else PPath="${Poster_Path}"; fi

if [ "${Sheet_Path}" = "MoviesPath" ]; then SPath="${Movies_Path}";
elif [ "${Sheet_Path}" = "SRJG" ]; then SPath="${Movies_Path}SRJG/ImgNfo";
else SPath="${Sheet_Path}"; fi

if [ "${Nfo_Path}" = "MoviesPath" ]; then NPath="${Movies_Path}";
elif [ "${Nfo_Path}" = "SRJG" ]; then NPath="${Movies_Path}SRJG/ImgNfo";
else NPath="${Nfo_Path}"; fi

# remove the Poster
[ "${Jukebox_Size}" = "EM_Poster" -o "${Jukebox_Size}" = "EM_Movie" ] && rm "${PPath}/${MFile}.jpg" 2>/dev/null

# remove the Sheet
[ "${Jukebox_Size}" = "EM_Sheet" -o "${Jukebox_Size}" = "EM_Movie" ] && rm "${SPath}/${MFile}_sheet.jpg" 2>/dev/null

# remove the Nfo
[ "${Jukebox_Size}" = "EM_Nfo" -o "${Jukebox_Size}" = "EM_Movie" ] && rm "${NPath}/${MFile}.nfo" 2>/dev/null

if [ "${Jukebox_Size}" = "EM_Movie" ]; then
  # remove the movie
  rm "${MPath}/${MFile}.${MExt}" 2>/dev/null
	
  # remove the movie from the database
  ${Sqlite} "${Database}"  "DELETE from t1 WHERE Movie_ID like '$Search'";
fi

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

MenuEdit()
{
# Menu to remove Poster, Sheet, Nfo or/and Movie File

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
  RedrawDisplay();
</onEnter>

<script>
  langpath = "${Jukebox_Path}lang/${Language}";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    lang_EditMenu = getXMLText("MEdit", "EditMenu");
    Lang_rmPoster = getXMLText("MEdit", "rmPoster");
    Lang_rmSheet = getXMLText("MEdit", "rmSheet");
    Lang_rmNfo = getXMLText("MEdit", "rmNfo");
		Lang_rmMovie = getXMLText("MEdit", "rmMovie");
  }
</script>

<mediaDisplay name="onePartView" rowCount="4" columnCount="1" sideLeftWidthPC="0" sideColorLeft="0:0:0" sideRightWidthPC="0" fontSize="14" focusFontColor="210:16:16" itemAlignt="center" viewAreaXPC=29.7 viewAreaYPC=26 viewAreaWidthPC=40 viewAreaHeightPC=50 headerImageWidthPC="0" itemImageHeightPC="0" itemImageWidthPC="0" itemXPC="10" itemYPC="15" itemWidthPC="80" itemHeightPC="10" itemBackgroundColor="0:0:0" itemGap="0" infoYPC="90" infoXPC="90" backgroundColor="0:0:0" showHeader="no" showDefaultInfo="no">
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
    <script>print("${Jukebox_Path}images/FBrowser_Bg.jpg");</script>
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=2 offsetYPC=0 widthPC=96 heightPC=10 fontSize=14 backgroundColor=-1:-1:-1    foregroundColor=70:140:210>
  <script>print(lang_EditMenu);</script>
</text>

<text align="left" offsetXPC=2 offsetYPC=89 widthPC=96 heightPC=10 fontSize=12 backgroundColor=-1:-1:-1    foregroundColor=200:200:200>
<script>MTitle=getEnv("MTitle");print(MTitle);</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      mode=getItemInfo(indx, "selection");
      SelParam=getItemInfo(indx, "param");
      YPos=getItemInfo(indx, "pos");
      jumpToLink("SelectionEntered");
      "false";
    }
  </script>
</onUserInput>

<itemDisplay>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
  if (getDrawingItemState() == "focus")
  {
      print("${Jukebox_Path}images/focus_on.png");
  }
 else
  {
      print("${Jukebox_Path}images/FBrowser_unfocus.png");
  }
    </script>
  </image>
	
<text redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="13" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>

</mediaDisplay>

<SelectionEntered>
    <link>
       <script>
           print("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?"+mode+"@"+SelParam+"@"+YPos+"@$CategoryTitle");
       </script>
    </link>
</SelectionEntered>

<channel>
<title>Edit Menu</title>

<item>
<title>
	<script>
    print ( Lang_rmPoster );
	</script>
</title>
<selection>EM_Poster</selection>
<param>no%20yes</param>
<pos>53</pos>
</item>

<item>
<title>
	<script>
    print ( Lang_rmSheet );
	</script>
</title>
<selection>EM_Sheet</selection>
<param>no%20yes</param>
<pos>53</pos>
</item>

<item>
<title>
	<script>
    print ( Lang_rmNfo );
	</script>
</title>
<selection>EM_Nfo</selection>
<param>no%20yes</param>
<pos>53</pos>
</item>

<item>
<title>
	<script>
    print ( Lang_rmMovie );
	</script>
</title>
<selection>EM_Movie</selection>
<param>no%20yes</param>
<pos>53</pos>
</item>

</channel>
</rss>
EOF
}

MenuSubT()
{
# Menu to choose Subtitle

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
  RedrawDisplay();
</onEnter>

<script>
  langpath = "${Jukebox_Path}lang/${Language}";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    lang_SubtMenu = getXMLText("MSubt", "SubtMenu");
    Lang_WtSubt = getXMLText("MSubt", "WtSubt");
  }
</script>

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
    <script>print("${Jukebox_Path}images/FBrowser_Bg.jpg");</script>
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=2 offsetYPC=0 widthPC=96 heightPC=10 fontSize=14 backgroundColor=-1:-1:-1 foregroundColor=70:140:210>
  <script>print(lang_SubtMenu);</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      SelParam=getItemInfo(indx, "param");
      setReturnString(SelParam);
      postMessage("return");
      "true";
    }
  </script>
</onUserInput>

<itemDisplay>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
  if (getDrawingItemState() == "focus")
  {
      print("${Jukebox_Path}images/focus_on.png");
  }
 else
  {
      print("${Jukebox_Path}images/FBrowser_unfocus.png");
  }
    </script>
  </image>
	
<text redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="13" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>

</mediaDisplay>

<channel>
<title>Subtitle Menu</title>

<item>
<title>
	<script>
    print ( Lang_WtSubt );
	</script>
</title>
<param>nosubtitle</param>
</item>
EOF

cat /tmp/srjg_srt_dir.list | while read ligne
do
  Nligne="${ligne##*/}"
cat <<EOF
<item>
<title>
	<script>
    print ( "${Nligne}" );
	</script>
</title>
<param>${ligne}</param>
</item>
EOF
done

cat <<EOF
</channel>
</rss>
EOF
}

MenuFont()
{
# Menu to choose Fonts

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
  RedrawDisplay();
</onEnter>

<script>
  langpath = "${Jukebox_Path}lang/${Language}";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    lang_FontMenu = getXMLText("MFont", "FontMenu");
  }
</script>

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
    <script>print("${Jukebox_Path}images/FBrowser_Bg.jpg");</script>
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=2 offsetYPC=0 widthPC=96 heightPC=10 fontSize=14 backgroundColor=-1:-1:-1 foregroundColor=70:140:210>
  <script>print(lang_FontMenu);</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      SelParam=getItemInfo(indx, "title");
      setReturnString(SelParam);
      postMessage("return");
      "true";
    }
  </script>
</onUserInput>

<itemDisplay>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
  if (getDrawingItemState() == "focus") print("${Jukebox_Path}images/focus_on.png");
  else print("${Jukebox_Path}images/FBrowser_unfocus.png");
    </script>
  </image>
	
<text redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="13" align="center">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>

</mediaDisplay>

<channel>
<title>Subtitle Menu</title>
EOF

if [ "${Subt_FontPath}" = "JukeboxPath" ]; then
  FontPath="${Jukebox_Path}font/"
else
  FontPath="${Subt_FontPath}"
fi

cat "/tmp/srjg_font_dir.list" | while read ligne
do
cat <<EOF
<item>
<title>${ligne}</title>
</item>
EOF
done

cat <<EOF
</channel>
</rss>
EOF
}

SeekPopup()
{
# Seek popup during video play
# Idea from Serge A. Timchenko
# http://code.google.com/media-translate/
# Credit to vb6rocod for subtitle add-on
# http://code.google.com/p/hdforall
# Modified and adapted to the srjg project

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
print("enter seek popup.rss");

	Config = "/usr/local/etc/srjg.cfg";
    Config_ok = loadXMLFile(Config);
    
	if (Config_ok == null) {
		print("Load Config fail ", Config);
	} else {
		Jukebox_Path = getXMLText("Config", "Jukebox_Path");
  }

img1=Jukebox_Path + "images/podcast_seek_bar_bg.bmp";
img2=Jukebox_Path + "images/podcast_seek_bar_fg.bmp";
bReturn = 1;

vidProgress = getEnv("videoStatus");
elapsed = getStringArrayAt(vidProgress, 0);
total = getStringArrayAt(vidProgress, 1);
/* if total time is longer than 30 seconds */
if (total &lt; 30)
{
	step_left = 1;
	step_right = 1;
}
else
{
	step_left = 10;
	step_right = 30;
}
if (total &gt; 0 &amp;&amp; total &lt; 1000000)
{
  arg_time = total;
	x = Integer(arg_time / 60);
	h = Integer(arg_time / 3600);
	s = arg_time - (x * 60);
	m = x - (h * 60);
	if(h &lt; 10) 
		ret_string = "0" + sprintf("%s:", h);
	else
		ret_string = sprintf("%s:", h);
	if(m &lt; 10)  ret_string += "0";
	ret_string += sprintf("%s:", m);
	if(s &lt; 10)  ret_string += "0";
	ret_string += sprintf("%s", s);
  stream_total = ret_string;
}
else
{
  stream_total = "";
}
redrawDisplay();
</onEnter>
	
<mediaDisplay
	name=photoView
	viewAreaXPC=40
	viewAreaYPC=2
	viewAreaWidthPC=59.77
	viewAreaHeightPC=21.39

	topArea.heightPC=0
	topArea.yPC=100
	bottomYPC=100

	drawItemBorder=no

	showHeader=no
	showDefaultInfo=no

	backgroundColor=-1:-1:-1
	itemBackgroundColor =-1:-1:-1
	itemGrid.elementBackground = -1:-1:-1
>

<image redraw=yes offsetXPC=40 offsetYPC=10 widthPC=50 heightPC=9>
<script>
img1;
</script>
</image>

<image redraw=yes offsetXPC=40 offsetYPC=10 heightPC=9>
<script>
img2;
</script>
<widthPC>
<script>
(elapsed/total)*50;
</script>
</widthPC>
</image>
<text offsetXPC=65 offsetYPC=20 heightPC=12  widthPC=26 backgroundColor=-1:-1:-1 foregroundColor=255:255:0 useBackgroundSurface=yes fontSize=12>
<script>
    arg_time = elapsed;
		x = Integer(arg_time / 60);
		h = Integer(arg_time / 3600);
		s = arg_time - (x * 60);
		m = x - (h * 60);
		if(h &lt; 10) 
			ret_string = "0" + sprintf("%s:", h);
		else
			ret_string = sprintf("%s:", h);
		if(m &lt; 10)  ret_string += "0";
		ret_string += sprintf("%s:", m);
		if(s &lt; 10)  ret_string += "0";
		ret_string += sprintf("%s", s);
    stream_elapsed = ret_string + " / " + stream_total;
    stream_elapsed;
</script>
</text>

<onUserInput>
ret = "false";
input = currentUserInput();
print("1user input is : ", input);
if (input == "right" || input == "R")
{
	elapsed = Add(elapsed, step_right);
	if (elapsed &gt; total)
	{
		elapsed = total;
	}
	redrawDisplay("widget");
	ret = "true";
}
else if (input == "left" || input == "L")
{
	elapsed = Minus(elapsed, step_left);
	if (elapsed &lt; 0)
	{
		elapsed = 0;
	}
	redrawDisplay("widget");
	ret = "true";
}
else if (input == "enter" || input == "ENTR")
{
	bReturn = 0;
	postMessage("return");
	/* avoid transition effect */
	redrawDisplay("no");
	ret = "true";
}
if (input == "return" || input == "RET")
{
	print("LOUIS - bReturn : ",bReturn);
	if (bReturn == 1)
	{
		elapsed = -1;
	}
	/* avoid transition effect */
	redrawDisplay("no");
	ret = "false";
}
else if (input == "video_completed" || input == "video_stop")
{
	bReturn = 0;
	playItemURL(-1, 1);
	postMessage("return");
	postMessage("return");
}
ret;
</onUserInput>
</mediaDisplay>


<channel>
<itemSize>
0
</itemSize>
</channel>

<onExit>
	stream_total="";
setReturnString(elapsed);
/* enable drawbackbuffer */
setRefreshTime(-1);
redrawDisplay("yes");

</onExit>

</rss>
EOF
}

NumberEdit()
{
# Edit numbers in the config
# Seek popup in Jukebox during move in Items, Idea from Cristian

Max_Item=${CategoryTitle}
PosX=${Jukebox_Size}
PosY=${Parm_4}
SelNum=${Parm_5}
PopupType=${Parm_6}
echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  ISelNum=${SelNum};
  SelNum=0;
  Max_Item=${Max_Item};
  showIdle();
  RedrawDisplay();
</onEnter>

<mediaDisplay name="onePartView" sideLeftWidthPC="0" sideColorLeft="0:0:0" sideRightWidthPC="0" viewAreaXPC="${PosX}" viewAreaYPC="${PosY}" viewAreaWidthPC="20" viewAreaHeightPC="10" headerImageWidthPC="0" infoYPC="90" infoXPC="90" backgroundColor="-1:-1:-1" showHeader="no" showDefaultInfo="no">

<backgroundDisplay>
  <image type="image/png" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
			if ( "${PopupType}" == "Seek" ) print("${Jukebox_Path}images/Seek_Button.png");
		  else print("${Jukebox_Path}images/focus_on.png");
		</script>
  </image>
</backgroundDisplay>

<text align="right" offsetXPC="30" offsetYPC="10" widthPC="60" heightPC="65" fontSize="16" backgroundColor="-1:-1:-1" foregroundColor="250:250:250">
  <script>
    if ( ISelNum != 0 ) print(ISelNum);
    else print(SelNum);
  </script>
</text>

<onUserInput>
    userInput = currentUserInput();

    InputNum=99;
    ret="false";
    if (userInput == "enter" ) {
      setReturnString(SelNum);
      postMessage("return");
      ret="true";
    } else if ( userInput == "one" ) { InputNum=1;
    } else if ( userInput == "two" ) { InputNum=2;
    } else if ( userInput == "three" ) { InputNum=3;
    } else if ( userInput == "four" ) { InputNum=4;
    } else if ( userInput == "five" ) { InputNum=5;
    } else if ( userInput == "six" ) { InputNum=6;
    } else if ( userInput == "seven" ) { InputNum=7;
    } else if ( userInput == "eight" ) { InputNum=8;
    } else if ( userInput == "nine" ) { InputNum=9;
    } else if ( userInput == "zero" ) { InputNum=0;
    } else if ( userInput == "right" ) { ret="true";
    } else if ( userInput == "left" ) {
      SelNum=Integer(SelNum / 10);
      RedrawDisplay();
      ret="true";
    }

    if ( InputNum != 99 ) {
      ISelNum = 0;
      SelNum=SelNum * 10;
      SelNum=Add(SelNum, InputNum);
      if ( Max_Item != 0 &amp;&amp; SelNum &gt;= Max_Item ) SelNum = Max_Item;
      InputNum=99;
      RedrawDisplay();
      ret="true";
    }
    ret;
</onUserInput>
</mediaDisplay>
<channel>
<title></title>
</channel>
</rss>
EOF
}

SubtFontchg()
{
# To change font file during play

echo -e '
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
showIdle();
postMessage("return");
</onEnter>
<mediaDisplay name="nullView"/>
EOF

if [ "${Subt_FontPath}" = "JukeboxPath" ]; then
  FontPath="${Jukebox_Path}font/"
else
  FontPath="${Subt_FontPath}"
fi

echo ${FontPath}${Subt_FontFile} >/tmp/srjg_fontname

echo '<channel></channel></rss>' # to close the RSS
exit 0
}

SubtPopup()
{
# Menu popup to setup subtitle during play

if [ "${Subt_FontPath}" = "JukeboxPath" ]; then
  FontPath="${Jukebox_Path}font/"
else
  FontPath="${Subt_FontPath}"
fi

echo -e '
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://purl.org/dc/elements/1.1/">
'
cat <<EOF
<onEnter>
  showIdle();
	Config = "/usr/local/etc/srjg.cfg";
  Config_ok = loadXMLFile(Config);
    
	if (Config_ok == null) {
		print("Load Config fail ", Config);
	} else {
		Subt_FontFile = getXMLText("Config", "Subt_FontFile");
		Subt_Color = getXMLText("Config", "Subt_Color");
		Subt_ColorBg = getXMLText("Config", "Subt_ColorBg");
		Subt_Size = getXMLText("Config", "Subt_Size");
  }
  RedrawDisplay();
</onEnter>

<script>
  langpath = "${Jukebox_Path}lang/${Language}";
  langfile = loadXMLFile(langpath);
  if (langfile != null) {
    lang_EditMenu = getXMLText("MEdit", "EditMenu");
		Lang_Subt_FontFile = getXMLText("Subt", "Subt_FontFile");
		Lang_Subt_Color = getXMLText("Subt", "Subt_Color");
		Lang_Subt_ColorBg = getXMLText("Subt", "Subt_ColorBg");
		Lang_Subt_Size = getXMLText("Subt", "Subt_Size");
		Lang_White = getXMLText("cfg", "white");
		Lang_Black = getXMLText("cfg", "black");
		Lang_Yellow = getXMLText("cfg", "yellow");
		Lang_Transparent = getXMLText("cfg", "transparent");
  }
</script>

<mediaDisplay name="onePartView" rowCount="4" columnCount="1" sideLeftWidthPC="0" sideColorLeft="0:0:0" sideRightWidthPC="0" fontSize="14" focusFontColor="210:16:16" itemAlignt="left" viewAreaXPC=29.7 viewAreaYPC=26 viewAreaWidthPC=40 viewAreaHeightPC=50 headerImageWidthPC="0" itemImageHeightPC="0" itemImageWidthPC="0" itemXPC="1.5" itemYPC="15" itemWidthPC="55" itemHeightPC="10" itemBackgroundColor="0:0:0" itemGap="0" infoYPC="90" infoXPC="90" backgroundColor="0:0:0" showHeader="no" showDefaultInfo="no">
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
    <script>print("${Jukebox_Path}images/FBrowser_Bg.jpg");</script>
  </image>
</backgroundDisplay>

<text align="center" offsetXPC=2 offsetYPC=0 widthPC=96 heightPC=10 fontSize=14 backgroundColor=-1:-1:-1 foregroundColor=70:140:210>
  <script>print(lang_EditMenu);</script>
</text>

<!-- Display config settings -->

<text redraw="yes" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="60" offsetYPC="18" widthPC="57" heightPC="6" fontSize="13" lines="1" align="left">
	<script>
		print( Subt_FontFile );
	</script>
</text>

<text redraw="yes" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="60" offsetYPC="28" widthPC="57" heightPC="6" fontSize="13" lines="1" align="left">
	<script>
		if ( Subt_Color == "white" ) print( Lang_White );
		else print( Lang_Yellow );
	</script>
</text>

<text redraw="yes" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="60" offsetYPC="38" widthPC="57" heightPC="6" fontSize="13" lines="1" align="left">
	<script>
		if ( Subt_ColorBg == "black" ) print( Lang_Black );
		else print( Lang_Transparent );
	</script>
</text>

<text redraw="yes" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" offsetXPC="60" offsetYPC="48" widthPC="57" heightPC="6" fontSize="13" lines="1" align="left">
	<script>
		print( Subt_Size );
	</script>
</text>

<onUserInput>
  <script>
    userInput = currentUserInput();
	
    if (userInput == "enter" ) {
      indx=getFocusItemIndex();
      mode=getItemInfo(indx, "selection");
      if ( mode == "Subt_FontFile" ) {
        FontSel="";
        dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?FontList@");
        M_FontFile = readStringFromFile( "/tmp/srjg_font_dir.list" );
        if ( M_FontFile != "" &amp;&amp; M_FontFile != null ) { /* Font file exists */
          /* if only one font file, it'll be selected else, you can select it */
          if ( getStringArrayAt(M_FontFile,1) == null || getStringArrayAt(M_FontFile,1) == "" ) FontSel=getStringArrayAt(M_FontFile,0);
          else FontSel=doModalRss("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?MenuFont@");
        }
        if ( FontSel !="" &amp;&amp; FontSel != null ) {
          UE_FontSel=urlEncode(FontSel);
          dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?UpdateCfg@"+UE_FontSel+"@Subt_FontFile@");
EOF

LoadCfg
SaveTmpCfg

cat <<EOF
          dlok = loadXMLFile("http://127.0.0.1:$Port/cgi-bin/srjg.cgi?SubtFontchg@");
        }
      } else {
        SelParam=getItemInfo(indx, "param");
        XPos=40;
        YPos=getItemInfo(indx, "pos");
        dlok = doModalRss("http://127.0.0.1:"+Port+"/cgi-bin/srjg.cgi?"+mode+"@"+SelParam+"@"+YPos+"@"+XPos);
      }
      executeScript("onEnter");
      "true";
    } else if (userInput == "edit") {
      postMessage("return");
      "true";
    }
  </script>
</onUserInput>

<itemDisplay>
  <image type="image/png" redraw="yes" offsetXPC="0" offsetYPC="0" widthPC="100" heightPC="100">
    <script>
  if (getDrawingItemState() == "focus") print("${Jukebox_Path}images/focus_on.png");
  else print("${Jukebox_Path}images/FBrowser_unfocus.png");
    </script>
  </image>
	
<text redraw="yes" offsetXPC="10" offsetYPC="0" widthPC="94" heightPC="100" backgroundColor="-1:-1:-1" foregroundColor="200:200:200" fontSize="13" align="left">
 <script>
    getItemInfo(-1, "title");
 </script>
</text>
</itemDisplay>

</mediaDisplay>

<channel>
<title>Edit Menu</title>

<item>
<title>
	<script>
		print(Lang_Subt_FontFile);
	</script>
</title>
<selection>Subt_FontFile</selection>
<param></param>
<pos></pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_Color);
	</script>
</title>
<selection>Subt_Color</selection>
<param>white%20yellow</param>
<pos>40</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_ColorBg);
	</script>
</title>
<selection>Subt_ColorBg</selection>
<param>transparent%20black</param>
<pos>40</pos>
</item>

<item>
<title>
	<script>
		print(Lang_Subt_Size);
	</script>
</title>
<selection>Subt_Size</selection>
<param>14%2018%2020%2022%2024%2026</param>
<pos>25</pos>
</item>

</channel>
</rss>
EOF
}

#***********************Main Program*********************************

case $mode in
  "WatcheUpDB") WatcheUpDB;; # Update DB for watched state
  "Update")
    if [ "$CategoryTitle" = "Rebuild" ]; then
      Force_DB_Update="y"
      Update
    elif [ "$CategoryTitle" = "Fast" ]; then
      Force_DB_Update=""
      Update
    else
      UpdateMenu;
    fi;;
  Jukebox_Size|SingleDb|Port|Nfo_Path|Poster_Path|Sheet_Path|UnlockRM|\
	Dspl_Genre_txt|Subt_OneAuto|Subt_Color|Subt_ColorBg|Subt_Size|Subt_Pos|Subt_FontPath|\
	Imdb|Imdb_Lang|Imdb_Source|\
  Imdb_Poster|Imdb_PBox|Imdb_PPost|Imdb_Sheet|\
  Imdb_SBox|Imdb_SPost|Imdb_Backdrop|Imdb_Font|\
  Imdb_Genres|Imdb_Tagline|Imdb_Time|Imdb_Info|\
  Lang) SubMenucfg;;   # display submenu to choose settings
  UpdateCfg) UpdateCfg;;    # update the cfg file
  DirList) DirList;;        # FBrowser list directorys
  FBrowser) FBrowser;;
  MenuCfg) MenuCfg;;
	ImdbSheetDspl) ImdbSheetDspl;;
  ImdbCfgEdit) ImdbCfgEdit;;
	DsplCfgEdit) DsplCfgEdit;;
  NumberEdit) NumberEdit;;
  ReplaceCd1byCd2) ReplaceCd1byCd2;;
  srtList) srtList;;
  FontList) FontList;;
	MenuEdit) MenuEdit;;
	EM_Poster|EM_Sheet|EM_Nfo|EM_Movie) SubMenuEdit;;
  DelMedia) DelMedia;;
  MenuSubT) MenuSubT;;
  MenuFont) MenuFont;;
  SubTitleGen) SubTitleGen;;
  PlayMovie) PlayMovie;;
  SeekPopup) SeekPopup;; # during video play
  SubtPopup) SubtPopup;; # Subtitle popup
  SubtFontchg) SubtFontchg;; # Subtitle font changer
  *)
    SetVar
    Header
    DisplayRss
    Footer;;
esac

exit 0
