#!/bin/bash

BASEDIR=`dirname $0`
MYSQL="/usr/bin/mysql"
MYSQLADMIN="/usr/bin/mysqladmin"
CRYPT="php -f $BASEDIR/magento_crypt.php"
DBUSER="myuser"
DBPASS="mypass"
DBNAME="magento"
UNSECUREURL="http://magento.host.com/"
SECUREURL="https://magento.host.com/"

if [ $# -lt 1 ]; then
  echo "Usage: setupdb.sh gzipdbsnapshot.gz"
  exit 1
fi;

echo "Dropping database $DBNAME in 5s, hit control-c NOW to abort!"
sleep 5;

echo "Importing DB from: $1"
$MYSQLADMIN -u$DBUSER -p$DBPASS -f drop $DBNAME
$MYSQLADMIN -u$DBUSER -p$DBPASS -f create  $DBNAME
gunzip -c $1 | $MYSQL -u$DBUSER -p$DBPASS $DBNAME

QUERIES=(
    "UPDATE core_config_data SET value = '$UNSECUREURL' WHERE path = 'web/unsecure/base_url'"
    "UPDATE core_config_data SET value = '$SECUREURL' WHERE path = 'web/secure/base_url'"
    # use test fedex account details
    "UPDATE core_config_data SET value='1' WHERE path='carriers/fedex/test_mode'"
    "UPDATE core_config_data SET value='`$CRYPT mykey`' WHERE path='carriers/fedex/key'"
    "UPDATE core_config_data SET value='`$CRYPT mypass`' WHERE path='carriers/fedex/password'"
    "UPDATE core_config_data SET value='`$CRYPT mymeterno`' WHERE path='carriers/fedex/meter'"
    "UPDATE core_config_data SET value='`$CRYPT myacctno`' WHERE path='carriers/fedex/account'"
    "UPDATE core_config_data SET value = 1 WHERE path = 'carriers/fedex/debug'"
    # use test auth.net account details
    "UPDATE core_config_data SET value='`$CRYPT mylogin`' WHERE path='payment/authorizenet/login'"
    "UPDATE core_config_data SET value='`$CRYPT mypass`' WHERE path='payment/authorizenet/trans_key'"
    "UPDATE core_config_data SET value='https://test.authorize.net/gateway/transact.dll' WHERE path='payment/authorizenet/cgi_url'"
    # use test usaepay account details
    "UPDATE core_config_data SET value='mysrckey' WHERE path='payment/usaepay/sourcekey'"
    "UPDATE core_config_data SET value='mypin' WHERE path='payment/usaepay/sourcepin'"
    "UPDATE core_config_data SET value = 1 WHERE path='payment/usaepay/sandbox'"
    # disable caching
    "UPDATE core_cache_option SET value = 0"
    "TRUNCATE core_cache"
    # enable logging
    "UPDATE core_config_data SET value = 1 WHERE path = 'dev/log/active'"
)
echo "Setting DB test defaults"
for QUERY in "${QUERIES[@]}"; do
  echo $QUERY | $MYSQL -u$DBUSER -p$DBPASS $DBNAME
done
echo "Done"
