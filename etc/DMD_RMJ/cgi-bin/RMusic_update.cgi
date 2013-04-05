#! /bin/sh
# GeekyHMB Random RSS Music Version 1.3 for HMB, Hyundai & Ellion box
# by Zozodesbois
# http://geekyhmb.fr.cr/content/Random_RSS_Music
# I give all rights to modify this script, but give my name and site.

CH_Scripts="/usr/local/etc/dvdplayer"
F_PListXml="${CH_Scripts}/Playlist.xml"
F_AListXml="${CH_Scripts}/Albumlist.xml"
F_Config="${CH_Scripts}/RMusic.cfg"

echo -e '<?xml version="1.0"   encoding="utf-8" ?>' # Ouverture du flux MaJ
echo -e '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">'

# lecture du fichier de config
CH_Music=`grep "<Chem>.*<.Chem>" "${F_Config}" | sed -e "s/^.*<Chem/<Chem/" | cut -f2 -d">"| cut -f1 -d"<"`

cd "${CH_Music}" # positionnement dans le dossier de musique

# echo -e '<channel> </channel>'  # Maintient du flux MaJ pour éviter un time-out

echo -e "<RMusic>">"${F_PListXml}"

# ajout de toutes les musiques avec leur balises
find . -print | grep -iE "\.aac|\.ac3|\.aiff|\.ape|\.fla|\.flac|\.m4a|\.mka|\.mp3|\.ogg|\.ra|\.wav|\.wma" | cut -c3- | sed -e 's/\&/\&amp;/g' -e 's/^/<music>/' -e 's/$/<\/music>/'>> "${F_PListXml}" 

NB=`sed -n '$=' "${F_PListXml}"` # compte le nombre de musiques
NB=`expr ${NB} - 2` # -1 pour l'entête et -1 parce que le premier élément commence à 0
echo -e "<RMCount>"${NB}"</RMCount>\n</RMusic>">>"${F_PListXml}" # ecriture du compteur et fermeture de la playlist

#find . -type d -print | cut -c3- | sed -e 's/\&/\&amp;/g' -e 's/^/<album>/' -e 's/$/<\/album>/'>> "/tmp/albumlist.txt"

echo -e "<AMusic>">"${F_AListXml}"

# create album playlist
find . -type d -print | cut -c3- | while read obj
do
d=${obj##*/}
fdir=${CH_Music}${obj}
pic=`ls "${fdir}" | grep -iE "folder.jpg"`
echo -e "<Aname>"${d}"</Aname>" | sed -e 's/\&/\&amp;/g' >> "${F_AListXml}"
echo -e "<Adir>"${obj}"</Adir>" | sed -e 's/\&/\&amp;/g' >> "${F_AListXml}"
echo -e "<Apic>"${pic}"</Apic>" | sed -e 's/\&/\&amp;/g' >> "${F_AListXml}"
#find "${fdir}" -print | grep -iE "/folder.jpg" | cut -c2- | head -n 1  >> "${F_AListXml}"
done
NB=`sed -n '$=' "${F_AListXml}"` # compte le nombre de musiques
NB=`expr ${NB} / 3 - 1` # -1 pour l'entête et -1 parce que le premier élément commence à 0
echo -e "<ACount>"${NB}"</ACount>\n</AMusic>">>"${F_AListXml}" # ecriture du compteur et fermeture de la playlist

echo -e '</rss>'                                # Fermeture du flux MaJ
exit 0
