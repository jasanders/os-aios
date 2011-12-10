#! /bin/sh

#if [ ! -f /usr/local/etc/directfbrc ] 
#then
     CUR_PATH=`pwd`
	TARGET_DIR=/usr/local/etc
     echo "s,\$(DFB_PATH),$CUR_PATH,g" > $TARGET_DIR/sed_script
   #  cp directfbrc.default $TARGET_DIR/directfbrc.default.new
   #  sed -i -f $TARGET_DIR/sed_script $TARGET_DIR/directfbrc.default.new
   #  cp directfbrc.default.new /usr/local/etc/directfbrc
     cp directfbrc.default $TARGET_DIR/directfbrc
     sed -i -f $TARGET_DIR/sed_script $TARGET_DIR/directfbrc
#fi

mkdir -p /usr/local/etc/qt-data

./path_link.sh
. ./ldpath.sh

if [ x$1 = xcntv ]
then
./bxManager &
fi
./DvdPlayer

