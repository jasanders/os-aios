#!/bin/sh
# Simple RSS Jukebox Generator -> DB to HTML converter
# Author: mikka [mika.hellmann@gmail.com]
# Modified by Snappy46 [levesque.marcel@gmail.com]
# Demo: http://members.home.nl/hellmann/

# Note: script is assuming that moviesheet is named filename_sheet.jpg and poster is named filename.jpg

# Paths
SRJGPATH="`sed '/<Jukebox_Path/!d;s:.*>\(.*\)</.*:\1:' /usr/local/etc/srjg.cfg | grep "[!-~]"`"
MOVPATH="`sed '/<Movies_Path/!d;s:.*>\(.*\)</.*:\1:' /usr/local/etc/srjg.cfg | sed 's/\"//g' | grep "[!-~]"`"
SINGLEDB="`sed '/<SingleDb/!d;s:.*>\(.*\)</.*:\1:' /usr/local/etc/srjg.cfg | grep "[!-~]"`"
POSTERPATH="`sed '/<Poster_Path/!d;s:.*>\(.*\)</.*:\1:' /usr/local/etc/srjg.cfg | grep "[!-~]"`"
SHEETSPATH="`sed '/<Sheet_Path/!d;s:.*>\(.*\)</.*:\1:' /usr/local/etc/srjg.cfg | grep "[!-~]"`"

TMPPATH="/tmp/db2html_path"
TMPHDD="/tmp/db2html_hdd"
TMPTITLE="/tmp/db2html_title"
TMPFILE="/tmp/db2html_file"
TMPEXT="/tmp/db2html_ext"

COLUMNS=10;						# Number of columns to be created
WIDTH=85;						# Width of poster to be displayed
HEIGHT=128;						# Height of poster to be displayed
IDX=1;							# Starting index
COUNT=1;						# Starting counter

USECATEG=0;						# Create alphabetical page categories (default Off)
USEDATE=0;						# Display creation date (default Off)
USESHEET=0;						# Include moviesheets (default Off)
USENUMBER=0;					# Display number of movies (default Off)
USESYMLINK=0;					# Use symlinks (default Off)
USETITLE=0;						# Show title (default Off)

usage()
{
cat << EOF
Usage: $0 options
Example: $0 -o /home/JukeboxHTML/ -a -d -m -s -t -c tar

This script converts SRJG movies.db to HTML jukebox. 

OPTIONS:
   -a	   Create alphabetical page categories (Optional, no argument needed)
   -c      Compress jukebox to archive: [tar] (Optional)
   -d	   Display creation date (Optional, no argument needed)
   -h      Show this message
   -m	   Include moviesheets (Optional, no argument needed)
   -n      Display number of movies
   -o      Output path to HTML jukebox (Optional) 
   -s	   Use symlinks (Optional, no argument needed)
   -t	   Display movie title (Optional, no argument needed)
   
NOTES:  If any of the path arguments have spaces in them they must be surrounded by quotes: ""
EOF
exit 1
}

while getopts o:c:adhmnst OPTION 
do
  case $OPTION in  
     o)	MAINPATH=$OPTARG	;;
     c)	PACK=$OPTARG		;;
     a)	USECATEG=1		;;
     d)	USEDATE=1		;;
     h)	usage			;;
     m)	USESHEET=1		;;
     n) USENUMBER=1		;;
     s) USESYMLINK=1		;;
     t)	USETITLE=1		;;
   esac
done


# If output path to HTML jukebox has NOT been provided, use main path from movies.db
if [ -z "$MAINPATH" ]
then
  MAINPATH="$MOVPATH"
fi


# Remove last character (which should be '/')
MOVPATH=$(echo ${MOVPATH%\/})
MAINPATH=$(echo ${MAINPATH%\/})
SRJGPATH=$(echo ${SRJGPATH%\/})
POSTERPATH=$(echo ${POSTERPATH%\/})
SHEETSPATH=$(echo ${SHEETSPATH%\/})

echo "Setting is set to $POSTERPATH"


# Initialize title and paths
DB2HTML="$SRJGPATH/db2html";		# Main path to db2html
SQLPATH="$SRJGPATH/sqlite3";		# Path to sqlite binary

HTMLPATH="$MAINPATH/SRJG"
IMGPATH="$MAINPATH/SRJG/images"
echo "Starting jukebox generation in $MAINPATH.."

# If image path doesn't exist, create folder for HTML jukebox
if [ ! -d "$IMGPATH" ];
then
  echo "Creating $IMGPATH.."
  mkdir -p "$IMGPATH"
fi

# Create symlink to HTML jukebox   (TO DO: remove all the same time - unique names)
echo "Creating symlinks.."
mount -o remount,rw /
rm -f /tmp/www/srjg
rm -f /tmp_orig/www/srjg
rm -f /tmp/www/hdd
rm -f /tmp_orig/www/hdd

rm -f /tmp/www/poster
rm -f /tmp_orig/www/poster
rm -f /tmp/www/sheet
rm -f /tmp_orig/www/sheet

ln -sf "$HTMLPATH" /tmp/www/srjg
ln -sf "$HTMLPATH" /tmp_orig/www/srjg
ln -sf "$MOVPATH" /tmp/www/hdd
ln -sf "$MOVPATH" /tmp_orig/www/hdd

if [ "$POSTERPATH" = "MoviesPath" ];
then
  REALPOSTER="different"
elif [ "$POSTERPATH" = "SRJG" ];
then
  ln -sf "$MOVPATH/SRJG/ImgNfo" /tmp/www/poster
  ln -sf "$MOVPATH/SRJG/ImgNfo" /tmp_orig/www/poster
  REALPOSTER="$MOVPATH/SRJG/ImgNfo"
else
  ln -sf "$POSTERPATH" /tmp/www/poster
  ln -sf "$POSTERPATH" /tmp_orig/www/poster
  REALPOSTER="$POSTERPATH"
fi

echo "Poster path is: $REALPOSTER"

if [ "$SHEETSPATH" = "MoviesPath" ];
then
  REALSHEET="different"
elif [ "$SHEETSPATH" = "SRJG" ];
then
  ln -sf "$MOVPATH/SRJG/ImgNfo" /tmp/www/sheet
  ln -sf "$MOVPATH/SRJG/ImgNfo" /tmp_orig/www/sheet
  REALSHEET="$MOVPATH/SRJG/ImgNfo"
else
  ln -sf "$SHEETSPATH" /tmp/www/sheet
  ln -sf "$SHEETSPATH" /tmp_orig/www/sheet
  REALSHEET="$SHEETSPATH"
fi

echo "Sheet path is: $REALSHEET"
  
# Default template header
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>SRJG Jukebox</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="StyleSheet" type="text/css" href="db2html.css">
</head>

<body>
<table align="center" width="1100"><tbody><tr><td>
<div class="title" align="center"><font color="#colortitle">Jukebox</font></div>' > "$HTMLPATH/index.html"

if [ $USEDATE = 1 ];
then
  echo "<br>Created on `date +"%Y-%m-%d %H:%M:%S"` with <b>db2html</b><br>" >> "$HTMLPATH/index.html"
fi

if [ $USECATEG = 1 ];
then
  echo '<br><div class="navigation" align="center">-' >> "$HTMLPATH/index.html"
		  
  for x in A B C D E F G H I J K L M N O P Q R S T U W X Y Z
  do
	echo '<a href="'"#$x"'">'"$x"'</a> -' >> "$HTMLPATH/index.html"
  done
  
  echo '</div><br>' >> "$HTMLPATH/index.html"
fi

# Path to movies.db
if [ $SINGLEDB = "yes" ];
then
	DBFILE="$SRJGPATH/movies.db"
else
	DBFILE="$MOVPATH/SRJG/movies.db"	
fi

# Get all required data
"$SQLPATH" -separator '' "$DBFILE" "SELECT path FROM t1 ORDER BY title COLLATE NOCASE" | sed -n '/<path>/,/<\/path>/s/.*<path>\(.*\)<\/path>/\1/p' > "$TMPPATH"

cat "$TMPPATH" | sed "s|$MOVPATH|/hdd|" > "$TMPHDD"

"$SQLPATH" -separator '' "$DBFILE" "SELECT title FROM t1 ORDER BY title COLLATE NOCASE" | sed -n '/<title>/,/<\/title>/s/.*<title>\(.*\)<\/title>/\1/p' > "$TMPTITLE"

"$SQLPATH" -separator '' "$DBFILE" "SELECT file FROM t1 ORDER BY title COLLATE NOCASE" | sed -n '/<file>/,/<\/file>/s/.*<file>\(.*\)<\/file>/\1/p' > "$TMPFILE"

"$SQLPATH" -separator '' "$DBFILE" "SELECT ext FROM t1 ORDER BY title COLLATE NOCASE" | sed -n '/<ext>/,/<\/ext>/s/.*<ext>\(.*\)<\/ext>/\1/p' > "$TMPEXT"

TOTALMOV="`sed -n '$=' "$TMPTITLE"`"
echo "Movies found: $TOTALMOV"

if [ $USENUMBER = 1 ];
then
  echo "<br>Total: $TOTALMOV movies" >> "$HTMLPATH/index.html"
fi

echo '<br><br><table align="center" cellpadding="1"><tbody><tr>' >> "$HTMLPATH/index.html"

# Copy basic files
echo "Copying basic files.."
cp "$DB2HTML/db2html.jpg" "$SRJGPATH/images/nofolder.jpg" "$SRJGPATH/images/NoMovieinfo.jpg" "$IMGPATH"
cp "$DB2HTML/db2html.css" "$HTMLPATH"

# Main loop
while read MOVIE
do
  echo "Processing $IDX: $MOVIE.."
  
  MHDD="`sed -n "$IDX"p "$TMPHDD"`"
  MFILE="`sed -n "$IDX"p "$TMPFILE"`"
  MEXT="`sed -n "$IDX"p "$TMPEXT"`"
  
  if [ "$REALPOSTER" = "different" ];
  then
	PPATH="`sed -n "$IDX"p "$TMPPATH"`"
	PSYM="$MHDD"
  else
	PPATH="$REALPOSTER"
	PSYM="/poster"
  fi

  if [ -e "$PPATH/$MFILE.jpg" ];
  then
	if [ $USESYMLINK = 0 ];
	then
	  cp "$PPATH/$MFILE.jpg" "$IMGPATH/p$IDX.jpg" 
	  SHOWPOSTER="images/p$IDX.jpg"
	else
	  SHOWPOSTER="$PSYM/$MFILE.jpg"
	fi
  else
	SHOWPOSTER="images/nofolder.jpg"
  fi
 
 
  if [ $USESHEET = 1 ];
  then
	
	if [ "$REALSHEET" = "different" ];
	then
	  SPATH="`sed -n "$IDX"p "$TMPPATH"`"
	  SSYM="$MHDD"
	else
	  SPATH="$REALSHEET"
	  SSYM="/sheet"
	fi
	
	if ( [ -e "${SPATH}/${MFILE}_sheet.jpg" ] && [ $USESYMLINK = 0 ] );
	then
	  cp "${SPATH}/${MFILE}_sheet.jpg" "$IMGPATH/m$IDX.jpg"
	  SHOWSHEET="images/m$IDX.jpg"
	elif ( [ -e "${SPATH}/${MFILE}_sheet.jpg" ] && [ $USESYMLINK = 1 ] );
	then
	  SHOWSHEET="${SSYM}/${MFILE}_sheet.jpg"  
	else
      SHOWSHEET="images/NoMovieinfo.jpg"
	fi
  else
    SHOWSHEET="#"
  fi
  
  
  if [ $USETITLE = 1 ];
  then
	SHOWTITLE='<br><strong><a href="'"$MHDD/$MFILE.$MEXT"'">'$MOVIE'</a></strong><br><br>'
  else
    SHOWTITLE=""
  fi
  
  
  if [ $USECATEG = 1 ];
  then
    L=`echo "$MOVIE" | cut -c1`
	SHOWCATEG='name="'$L'"'
  else
    SHOWCATEG=""
  fi
  
  echo '<td valign="top" width="'"$WIDTH"'" height="'"$HEIGHT"'"><center><a href="'"$SHOWSHEET"'" title="'"$MOVIE"'" '"$SHOWCATEG"' id="thumbimage"><img src="'"$SHOWPOSTER"'" width="'"$WIDTH"'" height="'"$HEIGHT"'"></a>'"$SHOWTITLE"'</center></td>' >> "$HTMLPATH/index.html"
  
  if [ $COUNT != $COLUMNS ];
  then
    let COUNT=$COUNT+1;
  else
    COUNT=1;
    echo '</tr><tr>' >> "$HTMLPATH/index.html"
  fi
  
  let IDX=$IDX+1;
done < "$TMPTITLE"


# Default template footer
echo '</tr></tbody></table></td></tr>'$SHOWDATE'</tbody></table></body></html>' >> "$HTMLPATH/index.html"

echo "Jukebox saved into $HTMLPATH"

# Pack everything
if [ "$PACK" == "tar" ];
then
  echo "Packing into $MAINPATH/html.tar.."
  tar -c -f "$MAINPATH"/html.tar -C "$MAINPATH" HTML/
fi
