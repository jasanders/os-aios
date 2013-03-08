#!/bin/sh
# Simple RSS Jukebox Generator -> IMDB plugin
# http://code.google.com/p/srjg/
# Author: mikka
# Project members :
# mikka [mika.hellmann@gmail.com]
# Snappy46 [levesque.marcel@gmail.com]
# Zozodesbois [geekyhmb@gmail.com]
#
# Documentation: http://playon.unixstorm.org/imdb.php

PAR_RSS="${1}"

# Reading/parsing xml configuration file and assign variables.

CfgFile=/usr/local/etc/srjg.cfg
if [ ! -f "${CfgFile}" ]; then
  echo "Configuration file not found: ${CfgFile}"
  exit 1
fi
sed '1d;$d;s:<\(.*\)>\(.*\)</.*>:\1=\2:' ${CfgFile} >/tmp/srjg.cfg
. /tmp/srjg.cfg

FSrjg_Path="${Movies_Path}SRJG/ImgNfo" # Possible storage for images and Nfo files to let clean the Movies_Path folder

PAR_LINK="http://playon.unixstorm.org/IMDB/movie_beta.php?name="			# Link to IMDB API [DO NOT CHANGE, unless you are requested to do so]
PAR_INFO="&mode=info&source=$Imdb_Source"													# Parameters for generating info file

PAR_SHEET="&mode=sheet&lang=$Imdb_Lang&font=$Imdb_Font&source=$Imdb_Source"		# Parameters for generating moviesheet
if [ $Imdb_Backdrop != "no" ]; then PAR_SHEET="$PAR_SHEET&backdrop=y"; fi
if [ $Imdb_SBox != "no" ]; then PAR_SHEET="$PAR_SHEET&box=$Imdb_SBox"; fi
if [ $Imdb_SPost != "no" ]; then PAR_SHEET="$PAR_SHEET&post=y"; fi
if [ $Imdb_Tagline != "no" ]; then PAR_SHEET="$PAR_SHEET&tagline=y"; fi
if [ $Imdb_Time != "no" ]; then PAR_SHEET="$PAR_SHEET&time=$Imdb_Time"; fi
if [ $Imdb_Genres != "no" ]; then PAR_SHEET="$PAR_SHEET&genres=$Imdb_Genres"; fi

PAR_POSTER="&mode=poster&source=$Imdb_Source"								# Parameters for generating poster
if [ $Imdb_PBox != "no" ]; then PAR_POSTER="$PAR_POSTER&box=$Imdb_PBox"; fi
if [ $Imdb_PPost != "no" ]; then PAR_POSTER="$PAR_POSTER&post=y"; fi

IMDB_TMP="/tmp/srjg_movies.list"				# Path to the list of movies [DO NOT CHANGE, unless you are requested to do so]
IMDB_DL_List="/tmp/imdb_dl.lst"					# List of download command
> ${IMDB_DL_List}												# empty list
	
IMDB_TITLE="filename"					# directory: Use directory name for IMDB search
										# filename: Use filename for IMDB search

download()
{
  INDX="${1}"
  DLINE=`sed "/^$INDX /!d;s:$INDX \(.*\):\1:" ${IMDB_DL_List}`
  DLINK="${DLINE%%@*}" # download link
  FNAME="${DLINE%@*}"
  FNAME="${FNAME##*@}" # Name of the file downloaded
  FCHCK="${DLINE##*@}" # type of check to test the download

  [ "$PAR_RSS" != "RSS_mode" ] && echo "downloading ${FNAME##*/}"

  # download poster, moviesheet or nfo file
  wget -q "${DLINK}" -O "${FNAME}"

  # Check generated file
  if [ ${FCHCK} = "Movie" ]; then TCHCK="found"; else TCHCK="title"; fi
  PATT=`grep ${TCHCK} "${FNAME}"`

  # Remove file if download is bad
  if ([ ${FCHCK} = "Movie" -a -e "${FNAME}" -a -n "$PATT" ] \
    || [ ${FCHCK} = "title" -a -e "${FNAME}" -a -z "$PATT" ] \
    || [ ! -s "${FNAME}" ]); then rm -f "${FNAME}"; fi
}
						
MkDlList()
{
  # Loop through all movies to generate the download command list
  INDX=1
  while read LINE
  do
	  MOVIEPATH="${LINE%/*}"					# Extract whole path
  	MOVIEEXT="${LINE##*/}"					# Extract filename 
  	MOVIEFILE="${MOVIEEXT%.*}"     			# Remove extension from filename

  	# Get movie name
  	if [ $IMDB_TITLE = "directory" ];
    then
      MOVIENAMETEMP="${MOVIEPATH##*/}"		# Use directory as moviename
    else
      MOVIENAMETEMP="$MOVIEFILE"				# Use file as moviename
    fi

    if [ "${Nfo_Path}" = "MoviesPath" ]; then NFOPATH="${MOVIEPATH}"; 
    elif [ "${Nfo_Path}" = "SRJG" ]; then NFOPATH="${FSrjg_Path}"
    else NFOPATH="${Nfo_Path}"; fi

    if [ "${Poster_Path}" = "MoviesPath" ]; then POSTERPATH="${MOVIEPATH}"; 
    elif [ "${Poster_Path}" = "SRJG" ]; then POSTERPATH="${FSrjg_Path}"
    else POSTERPATH="${Poster_Path}"; fi

    if [ "${Sheet_Path}" = "MoviesPath" ]; then SHEETPATH="${MOVIEPATH}"; 
    elif [ "${Sheet_Path}" = "SRJG" ]; then SHEETPATH="${FSrjg_Path}"
    else SHEETPATH="${Sheet_Path}"; fi

    # Remove CD parts, (1991)(1080p) and replace special characters with plus sign
    MOVIENAME=`echo $MOVIENAMETEMP | sed "s/[cC][dD]*[1-9]//g;s/[ &']/+/g;s/(.*)//"`
	
    # Download poster
    if ( [ $Imdb_Poster = "yes" ] && [ ! -e "$POSTERPATH/${MOVIEFILE}.jpg" ] )
    then
      NAME="$POSTERPATH/${MOVIEFILE}.jpg"
      let INDX+=1
      echo "$INDX $PAR_LINK$MOVIENAME$PAR_POSTER@$NAME@Movie" >>${IMDB_DL_List}
    fi

    # Download moviesheet
    if ( [ $Imdb_Sheet = "yes" ] && [ ! -e "$SHEETPATH/${MOVIEFILE}_sheet.jpg" ] )
    then
      NAME="$SHEETPATH/${MOVIEFILE}_sheet.jpg"
      let INDX+=1
      echo "$INDX $PAR_LINK$MOVIENAME$PAR_SHEET@$NAME@Movie" >>${IMDB_DL_List}
    fi
	
    # Download NFO file
    if ( [ $Imdb_Info = "yes" ] && [ ! -e "$NFOPATH/$MOVIEFILE.nfo" ] && [ ! -e "$NFOPATH/MovieInfo.nfo" ] )
    then
      NAME="$NFOPATH/${MOVIEFILE}.nfo"
      let INDX+=1
      echo "$INDX $PAR_LINK$MOVIENAME$PAR_INFO@$NAME@title">>${IMDB_DL_List}
    fi
  done < "$IMDB_TMP"
}

# Create moviesheets by calling IMDB API
[ "$PAR_RSS" != "RSS_mode" ] && echo "Starting IMDB API.."
MkDlList
[ "$PAR_RSS" != "RSS_mode" ] && echo "Starting download.."
if [ -n ${IMDB_DL_List} ]; then
  exec 3< ${IMDB_DL_List}       # list to be processed
  i=1;
  while [ $i -le $Imdb_MaxDl ]  # multi process download
  do
    (while read REPLY; do download $REPLY; done) <&3 &
    let i+=1
  done
  wait
fi
[ "$PAR_RSS" != "RSS_mode" ] && echo "Finished IMDB API.."
