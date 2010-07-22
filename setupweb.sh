#!/bin/bash

USER=""
PASS=""
HOST=""
DBNAME=""

if [ $# -lt 2 ]; then
  echo "Usage: setupweb.sh bzip2websnapshot.tar.bz2 destination-dir"
  exit 1
fi;

STORE="$2/store"

rm -rf $STORE
tar -C $2 -jxvf $1
rm -rf $STORE/var/*
sed -i '' "s/$LIVEDBUSER/$USER/" $STORE/app/etc/local.xml         
sed -i '' "s/$LIVEDBPASS/$PASS/" $STORE/app/etc/local.xml 
sed -i '' "s/$LIVEDBHOST/$HOST/" $STORE/app/etc/local.xml 
sed -i '' "s/$LIVEDBNAME/$DBNAME/" $STORE/app/etc/local.xml 
sed -i '' "s/i:1/i:0/g" $STORE/app/etc/use_cache.ser
# disable caching
perl -e 'while (<>) { $content .= $_; } $content =~ s#\s{8}<cache.*</cache>\n##s; print $content;' < $STORE/app/etc/local.xml > $STORE/app/etc/local.xml.tmp
mv $STORE/app/etc/local.xml.tmp $STORE/app/etc/local.xml

chmod -R 777 $STORE/app $STORE/var/ $STORE/media/ $STORE/app/etc/ $STORE/media/downloadable/ $STORE/media/import/ $STORE/app/etc/use_cache.ser
