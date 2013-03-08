#!/bin/sh
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

NAS1_IP="192.168.1.1"
NAS1_SHARE="Volume_1"
NAS1_MEDIA_FOLDER1="Media/En Movies"
MOUNT_NAS1_SHARE="NAS1"
MOUNT_NAS1_MEDIA_FOLDER1="Movies1"

# Create nfs mount folder if not present
mkdir -p /tmp/nfs

# COPY THIS BLOCK FOR EVERY SERVER YOU WANT TO LINK TO
######################################################
TIMEOUT=20
mkdir -p /tmp/ramfs/volumes/$MOUNT_NAS1_SHARE 
while [ $TIMEOUT -gt 0 ]; do
    if ping $NAS1_IP; then   
        mount -t cifs //$NAS1_IP/$NAS1_SHARE -o ro,username= /tmp/ramfs/volumes/$MOUNT_NAS1_SHARE
        ln -s /tmp/ramfs/volumes/$MOUNT_NAS1_SHARE/$NAS1_MEDIA_FOLDER1 /tmp/nfs/$MOUNT_NAS1_MEDIA_FOLDER1
        TIMEOUT=0
    else
        TIMEOUT=$((TIMEOUT - 1))
    fi
done
##########################################################

IFS=$SAVEIFS
