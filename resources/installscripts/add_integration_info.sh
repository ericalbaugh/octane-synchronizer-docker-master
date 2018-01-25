#!/bin/bash

mkdir /opt/octane/apikeys
/opt/octane/install/generateadminapikey.sh http://localhost:8080 sa@nga Password1 > /opt/octane/apikeys/octaneapikey.json

APIKEY=`cat /opt/octane/apikeys/octaneapikey.json | grep client_id | awk '{ sub(/^[^:]*:[[:blank:]]*/, "", $0); print $0; }' | cut -d '"' -f 2`
APISECRET=`cat /opt/octane/apikeys/octaneapikey.json | grep client_secret | awk '{ sub(/^[^:]*:[[:blank:]]*/, "", $0); print $0; }' | cut -d '"' -f 2`
sed -i -e "s,Service_Integration_Api_key,$APIKEY,g" /opt/ibs/conf/ibs.yml
sed -i -e "s,Service_Integration_Api_secret,$APISECRET,g" /opt/ibs/conf/ibs.yml
sed -i -e "s,Service_Integration_Api_key,$APIKEY,g" /opt/sync/conf/sync.yml
sed -i -e "s,Service_Integration_Api_secret,$APISECRET,g" /opt/sync/conf/sync.yml
