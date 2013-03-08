#!/bin/sh
# Simple RSS Jukebox Generator

# To kill all childs process when need to stop the script
trap "kill 0" SIGINT

# Reading/parsing xml configuration file and assign variables.

CfgFile=/usr/local/etc/srjg.cfg
if [ ! -f "${CfgFile}" ]; then
  echo "Configuration file not found: ${CfgFile}"
  exit 1
fi
sed '1d;$d;s:<\(.*\)>\(.*\)</.*>:\1=\2:' ${CfgFile} >/tmp/srjg.cfg
. /tmp/srjg.cfg

# Setting up other variable
if [ "${SingleDb}" = "yes" ]; then 
  Database="${Jukebox_Path}movies.db"
  PreviousMovieList="${Jukebox_Path}prevmovies.list"
else
  Database="${Movies_Path}SRJG/movies.db"
  PreviousMovieList="${Movies_Path}SRJG/prevmovies.list"
fi

# Initialize some Variables

MoviesList="/tmp/srjg_movies.list"
InsertList="/tmp/srjg_insert.list"
DeleteList="/tmp/srjg_delete.list"
ExluList="/tmp/srjg_exclu.list"
IMDB=""
Force_DB_Update=""
Sqlite="${Jukebox_Path}sqlite3"

usage()
# Display help menu
{
cat << EOF
usage: $0 options

This script creates a Movie / TV Episode on a specified directory.

OPTIONS:
   -h      Show this message
   -p      This indicate the jukebox directory ex: -p /HDD/movies/
   -f      This is the filter option, movies filename containing this/those
           string(s) will be skipped.  Strings must be separated by a ","
           (Optional) ex: -f sample,trailer
   -g      Generate moviesheets, thumbnails and NFO files. (Optional)
           Please refer to ${Jukebox_Path}imdb.sh for additional settings.
   -u      Forces the rebuild of the movies database.  If you suspect that your movies.db
           is corrupted or made changes that require a full database update use -u.
NOTES:  If any of the arguments have spaces in them they must be surrounded by quotes: ""
    
EOF
exit 1
}

#------------------------
# Parsing parameters 
#------------------------
while getopts p:f:ghu OPTION 
do
  case $OPTION in
     p)
       Movies_Path=$OPTARG
       if [ ! -d "${Movies_Path}" ]			# ctrl directory param
       then
         echo -e "The specified directory doesn't exist: ${Movies_Path}"
         exit 1
       fi
       sed -i "s:\(Movies_Path>\)\(.*\)\(</.*\):\1\"${Movies_Path}\"\3:" ${CfgFile}	# write param in cfg file
       ;;
     f)
       Movie_Filter=$OPTARG
       sed -i "s:\(Movie_Filter>\)\(.*\)\(</.*\):\1${Movie_Filter}\3:" ${CfgFile}	# write param in cfg file
       ;;
     g)
       IMDB=y
       ;;
     h)
       usage
       ;;
     u)
       Force_DB_Update=y
   esac
done

if [ ! -d "${Movies_Path}" ]; then			# ctrl directory cfg file
  echo -e "The Movies_Path specified directory in ${CfgFile} doesn't exist: ${Movies_Path}"
  exit 1
fi

([ "${SingleDb}" = "no" ] && [ ! -d "${Movies_Path}SRJG/" ]) && mkdir -p "${Movies_Path}SRJG/"

if ([ "${Nfo_Path}" = "SRJG" ] || [ "${Sheet_Path}" = "SRJG" ] || [ "${Poster_Path}" = "SRJG" ]) ; then
  [ ! -d "${Movies_Path}SRJG/ImgNfo/" ] && mkdir -p "${Movies_Path}SRJG/ImgNfo/"
  FSrjg_Path="${Movies_Path}SRJG/ImgNfo" # Possible storage for images and Nfo files to let clean the Movies_Path folder
  if [ ! -d "${FSrjg_Path}" ]; then echo "The specified directory doesn't exist: ${FSrjg_Path}"; exit 1 ; fi
fi

if [ "${Nfo_Path}" != "MoviesPath" ] && [ "${Nfo_Path}" != "SRJG" ] &&[ ! -d "${Nfo_Path}" ]; then
  echo "The specified directory doesn't exist: ${Nfo_Path}"
  exit 1
fi

if [ "${Sheet_Path}" != "MoviesPath" ] && [ "${Sheet_Path}" != "SRJG" ] &&[ ! -d "${Sheet_Path}" ]; then
  echo "The specified directory doesn't exist: ${Sheet_Path}"
  exit 1
fi

if [ "${Poster_Path}" != "MoviesPath" ] && [ "${Poster_Path}" != "SRJG" ] &&[ ! -d "${Poster_Path}" ]; then
  echo "The specified directory doesn't exist: ${Poster_Path}"
  exit 1
fi

CreateMovieDB()
# Create the Movie Database
# DB as an automatic datestamp but unfortunately it relies on the player having the
# correct date which can be trivial with some players.
{
echo "Creating Database..."
${Sqlite} "${Database}" \
   "create table t1 (Movie_ID INTEGER PRIMARY KEY AUTOINCREMENT,genre TEXT,title TEXT,year TEXT,path TEXT,file TEXT,ext TEXT,watched INTEGER,dateStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
${Sqlite} "${Database}" "create table t2 (header TEXT, footer TEXT, IdMovhead TEXT, IdMovFoot TEXT, WatchedHead TEXT, WatchedFoot TEXT)";
${Sqlite} "${Database}" "insert into t2 values ('<item>','</item>','<IdMovie>','</IdMovie>','<Watched>','</Watched>')";
}

Force_DB_Creation()
# Force creation of the Database using the "u" parameter option
# This option can be use to start up with a fresh database in case of
# Database corruption
{
rm "${PreviousMovieList}" 2>/dev/null
rm "${Database}" 2>/dev/null
CreateMovieDB;
}

GenerateMovieList()
# Find the movies based on movie extension and path provided.
# Remove movies: 
# - That contains the string(s) specified in $Movie_Filter
# - In all path that contains files exclu.txt
{
# Replace the comma in Movie_Filter to pipes |
Movie_Filter=`echo ${Movie_Filter} | sed 's/,/|/ g'`
echo "Searching for movies.."
find "${Movies_Path}" \
  | egrep -i 'exclu.txt|\.(asf|avi|dat|divx|flv|img|iso|m1v|m2p|m2t|m2ts|m2v|m4v|mkv|mov|mp4|mpg|mts|qt|rm|rmp4|rmvb|tp|trp|ts|vob|wmv)$' \
  | egrep -iv "${Movie_Filter}" > ${MoviesList}

# create exclu path list
sed '/exclu.txt/!d;s:\(.*/\)\([^/]*\):\\\#\1\#d:' ${MoviesList} >${ExluList}
# remove exlu path
[ -s "${ExluList}" ] && sed -i -f ${ExluList} ${MoviesList}

echo "Found `sed -n '$=' ${MoviesList}` movies"
}


Infoparsing()
# Parse nfo file to extract movie title, genre and year
{
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
GENRE=`sed -e '/<genre>/,/\/genre>/!d;/genre>/d' -f "${Jukebox_Path}lang/${Lang}_genreGrp" "$NFOPATH/$INFONAME"`
MovieYear=`sed '/<year>/!d;s:.*>\(.*\)</.*:\1:' "$NFOPATH/$INFONAME"`            
}


GenerateInsDelFiles()
# Generate insertion and deletion files
{
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


DBMovieInsert()
# Add movies to the Database and extract movies posters/folders
{
echo "Adding movies to the Database ...."
 
while read LINE_I
do
  MOVIEPATH="${LINE_I%/*}"  # Shell builtins instead of dirname
  MOVIEFILE="${LINE_I##*/}" # Shell builtins instead of basename
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

  if [ -n "$Force_DB_Update" ]; then
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


DBMovieDelete()
# Delete records from the movies.db database.
{
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


#*****************  Main Program  *****************************************

GenerateMovieList;
([ "$Imdb" = "yes" ] || [ -n "$IMDB" ]) &&  ${Jukebox_Path}imdb.sh
[ -n "$Force_DB_Update" ] && Force_DB_Creation
[ ! -f "${Database}" ] && CreateMovieDB
echo Indexing $Movies_Path;
# if full update required then just delete (rm) ${PreviousMovieList}
GenerateInsDelFiles;
[[ -s $DeleteList ]] && DBMovieDelete
[[ -s $InsertList ]] && DBMovieInsert
echo -e "\nDone!"
# Force disk buffers to be written
sync

