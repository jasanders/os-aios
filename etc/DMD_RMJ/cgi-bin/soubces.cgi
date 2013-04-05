#!/bin/sh
echo -e '<?xml version="1.0"   encoding="utf-8" ?>'
echo -e '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">'

# set the 'file' variable first
file=`sed -n '1p' /tmp/rmjukebox.dat`
# get extension; everything after last '.'
ext=${file##*.}

# basename
#basename=`basename "$file"`
# everything after last '/'
basename=${file##*/}
# songname=${file##*/}
songname0="${basename%.*}"
songname="${songname0:-$basename}"

# dirname
#dirname=`dirname "$file"`
# everything before last '/'
dirname=${file%/*}
basedir=`echo ${dirname} | cut -c20-`
albumname=`basename "$basedir"`
albumdir=`dirname "$basedir"`
nextsong=`head /dev/urandom | tr -dc 0-9 | cut -c1-10`

# rmfila=`basename $QUERY_STRING` | sed -e 's/\..*//'
# rmdira=`dirname $QUERY_STRING`
# fname=${rmfila}
echo $file > /tmp/rmjukebox.dat
echo $nextsong  >> /tmp/rmjukebox.dat
echo $(date "+%s")  >> /tmp/rmjukebox.dat
echo $dirname >> /tmp/rmjukebox.dat
echo $albumdir >> /tmp/rmjukebox.dat
echo $albumname >> /tmp/rmjukebox.dat
echo $songname >> /tmp/rmjukebox.dat
echo $ext  >> /tmp/rmjukebox.dat
# echo $basedir  > /tmp/rmjukebox.dat
# echo `basename $QUERY_STRING` | sed -e 's/\..*//' > /tmp/rmjukebox.dat
# basename $QUERY_STRING > /tmp/rmjukebox.dat
# dirname $QUERY_STRING > /tmp/rmjukebox.dat

 cd "$(dirname "$file")"
 find . -print | grep -iE "/folder.jpg" | cut -c2- >> /tmp/rmjukebox.dat


 echo -e "<RMusic>"> /tmp/album.xml

# ajout de toutes les musiques avec leur balises
find . -print | grep -iE "\.aac|\.ac3|\.aiff|\.ape|\.fla|\.flac|\.m4a|\.mka|\.mp3|\.ogg|\.ra|\.wav|\.wma" | cut -c2- | sed -e 's/\&/\&amp;/g' -e 's/^/<music>/' -e 's/$/<\/music>/'>> /tmp/album.xml 

NB=`sed -n '$=' /tmp/album.xml` # compte le nombre de musiques
NB=`expr ${NB} - 2` # -1 pour l'entête et -1 parce que le premier élément commence à 0
echo -e "<RMCount>"${NB}"</RMCount>\n</RMusic>">>/tmp/album.xml # ecriture du compteur et fermeture de la playlist

echo -e '</rss>'
exit 0




