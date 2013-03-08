#!/bin/sh
# Author: Snappy46 [levesque.marcel@gmail.com]

moviesPath=$1
moviesList="/tmp/movieList.txt"

printInstructions()
{
echo ""
echo 'This script will search thru the specified path for any file named about.jpg,0001.jpg, or folder.jpg and will rename them or copy them over as Moviefilename_sheet.jpg and Moviefilename.jpg respectively for proper operation with SRJG. If you wish to keep the original files you must select the copy option otherwise your original files will be renamed. If a space exist in the directory path it must be put between quotation mark (").'
echo ""
echo "Usage: srjg_naming [MOVIES_DIR]"
echo ""
echo "Example: srjg_naming /usbmounts/movies/"
echo '         srjg_naming "/tmp/usbmounts/Kids Movies/"'
echo ""
}


chkdir() 
{
  if [ ! -d "${moviesPath}" ];
  then 
	echo "Directory specified could not be found"
	exit 1		  
  fi 
  return 0 ;
}


GenerateMovieList()
# Find the movies based on movie extension and path provided.
{
echo "Searching for movies..."
find "${moviesPath}" | egrep -i '\.(asf|avi|dat|divx|flv|img|iso|m1v|m2p|m2t|m2ts|m2v|m4v|mkv|mov|mp4|mpg|mts|qt|rm|rmp4|rmvb|tp|trp|ts|vob|wmv)$' > $moviesList
}

renamefiles()
{
echo -n "Renaming your thumbnails and moviesheets ..."
while read LINE
do
MOVIEPATH="${LINE%/*}"
MOVIEFILE="${LINE##*/}"
MOVIENAME="${MOVIEFILE%.*}"

for FILE in "about.jpg" "0001.jpg" "poster.jpg"
do
  [ ! -e "$MOVIEPATH/$FILE" ] && continue
  mv "${MOVIEPATH}/${FILE}" "${MOVIEPATH}/${MOVIENAME}_sheet.jpg"
  break
done

for FILE in "folder.jpg"
do
  [ ! -e "$MOVIEPATH/$FILE" ] && continue
  mv "${MOVIEPATH}/${FILE}" "${MOVIEPATH}/${MOVIENAME}.jpg"
  break
done

echo -n "."
done < $moviesList
}


copyfiles()
{
echo -n "Copying your thumbnails and moviesheets to SRJG naming convention ..."
while read LINE
do
MOVIEPATH="${LINE%/*}"
MOVIEFILE="${LINE##*/}"
MOVIENAME="${MOVIEFILE%.*}"

for FILE in "about.jpg" "0001.jpg" "poster.jpg"
do
  [ ! -e "$MOVIEPATH/$FILE" ] && continue
  cp "${MOVIEPATH}/${FILE}" "${MOVIEPATH}/${MOVIENAME}_sheet.jpg"
  break
done

for FILE in "folder.jpg"
do
  [ ! -e "$MOVIEPATH/$FILE" ] && continue
   cp "${MOVIEPATH}/${FILE}" "${MOVIEPATH}/${MOVIENAME}.jpg"
  break
done

echo -n "."

done < $moviesList
}

if [ "${moviesPath}" = "" ]; then
  printInstructions;
  exit 1;
else
   chkdir;
fi

clear
echo
echo "Please select option:"
echo -e "c) To copy files"
echo -e "r) To rename files"
echo -e "q) To quit"
echo
echo -n "Enter your selection and press [ENTER]: "

read selection

if [ $selection = "c" ]; then
  GenerateMovieList;
  copyfiles;

elif [ $selection = "r" ]; then
   GenerateMovieList;
   renamefiles;
else
  exit 0;
fi

echo ""
echo "Operation was successful, enjoy SRJG !"
echo ""
exit 0;




