#! /bin/sh
#export LD_LIBRARY_PATH=../../../lib:../../../lib_release:../../../qt-data/lib:../../../qt-data/plugins

QT_DATA_PATH=/usr/local/etc/qt-data
rm -f $QT_DATA_PATH/lib
rm -f $QT_DATA_PATH/plugins

mkdir -p $QT_DATA_PATH

ORG_DIR=`pwd`
cd ./qt-data

ln -s `pwd`/lib /usr/local/etc/qt-data/lib
ln -s `pwd`/plugins /usr/local/etc/qt-data/plugins

cd $ORG_DIR
echo "done"

