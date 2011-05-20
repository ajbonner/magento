#!/bin/bash

SNAPDBUSER="myremoteuser"
SNAPDBPASS="myremotepass"
SNAPDBHOST="myremotehost"
SNAPDBNAME="myremotedbname"
LOCALDBUSER="myuser"
LOCALDBPASS="mypass"
LOCALDBHOST="127.0.0.1"
LCOCALDBNAME="magento"
SED="/bin/sed"

if [ $# -lt 2 ]; then
  echo "Usage: setupweb.sh bzip2websnapshot.tar.bz2 destination-dir"
  exit 1
fi;

STORE="$2"
if [ ! -d $STORE ]; then
    echo "Destination directory does not exist, creating it..."
    mkdir $STORE
fi

rm -rf $STORE
tar -C $2 -jxvf $1
$SED -i'' "s/\(<dbname>.*\)$SNAPDBNAME/\\1$LOCALDBNAME/" $STORE/app/etc/local.xml
$SED -i'' "s/\(<username>.*\)$SNAPDBUSER/\\1$LOCALDBUSER/" $STORE/app/etc/local.xml
$SED -i'' "s/$SNAPDBPASS/$LOCALDBPASS/" $STORE/app/etc/local.xml
chmod -R 777 $STORE/var/ $STORE/media/ $STORE/app/etc/ $STORE/media/downloadable/
# remove caching configuration
perl -e 'while (<>) { $content .= $_; } $content =~ s#\s{8}<cache.*</cache>\n##s; print $content;' < $STORE/app/etc/local.xml > $STORE/app/etc/local.xml.tmp
mv $STORE/app/etc/local.xml.tmp $STORE/app/etc/local.xml
# nuke var cache files which can cause issues
rm -rf $STORE/var/cache
