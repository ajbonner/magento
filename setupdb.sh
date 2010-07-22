#!/bin/bash

BASEDIR=`dirname $0`
MYSQLADMIN="/opt/local/bin/mysqladmin5"
CRYPT="php -f $BASEDIR/magento_crypt.php"
MYSQL="/opt/local/bin/mysql5"
USER=""
PASS=""
DBNAME=""
DEVDBNAME=""
BASEURL=""
DEVBASEURL=""
FEDEXKEY=""
FEDEXPASSWORD=""
FEDEXMETER=""
FEDEXACCOUNT=""
AUTHNETLOGIN=""
AUTHNETTRANSKEY=""
AUTHNETURL=""
if [ $# -lt 1 ]; then
  echo "Usage: setupdb.sh gzipdbsnapshot.gz [dev]"
  exit 1
fi;

if [ $# -eq 2 ]; then
  if [ $2 = "dev" ]; then
    DBNAME=$DEVDBNAME
    BASEURL=$DEVBASEURL
  fi;
fi;

echo "Dropping database $DBNAME in 5s, hit control-c NOW to abort!"
sleep 5;

echo "Importing DB from: $1"
$MYSQLADMIN -u$USER -p$PASS -f drop $DBNAME
$MYSQLADMIN -u$USER -p$PASS -f create  $DBNAME
gzcat $1 | $MYSQL -u$USER -p$PASS $DBNAME

QUERY1="UPDATE core_config_data SET value = 'http://$BASEURL/store/' WHERE path = 'web/unsecure/base_url'"
QUERY2="UPDATE core_config_data SET value = 'https://$BASEURL/store/' WHERE path = 'web/secure/base_url'"
# use test fedex account details
QUERY3="UPDATE core_config_data SET value='1' WHERE path='carriers/fedex/test_mode'"
QUERY4="UPDATE core_config_data SET value='`$CRYPT $FEDEXKEY`' WHERE path='carriers/fedex/key'"
QUERY5="UPDATE core_config_data SET value='`$CRYPT $FEDEXPASSWORD`' WHERE path='carriers/fedex/password'"
QUERY6="UPDATE core_config_data SET value='`$CRYPT $FEDEXMETER`' WHERE path='carriers/fedex/meter'"
QUERY7="UPDATE core_config_data SET value='`$CRYPT $FEDEXACCOUNT`' WHERE path='carriers/fedex/account'"
# use test auth.net account details
QUERY8="UPDATE core_config_data SET value='`$CRYPT $AUTHNETLOGIN`' WHERE path='payment/authorizenet/login'"
QUERY9="UPDATE core_config_data SET value='`$CRYPT $AUTHNETTRANSKEY`' WHERE path='payment/authorizenet/trans_key'"
QUERY10="UPDATE core_config_data SET value='$AUTHNETURL' WHERE path='payment/authorizenet/cgi_url'"

echo "Setting DB test defaults"
for i in `seq 1 10`; do
  eval QUERY="\${QUERY${i}}"
  echo $QUERY | $MYSQL -u$USER -p$PASS $DBNAME
done
echo "Done"
