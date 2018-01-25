#!/bin/bash
if [ "$1" = "" ] | [ "$2" = "" ] | [ "$3" = "" ]
then
    echo usage: configure_bridge_links.sh \<octane-url:port\> \<sa_username\> \<password\>
    echo example: configure_bridge_links.sh http://octance-server.com:8080 sa@octane.com P@ssWord
    exit 2
fi

cd /tmp

echo "Adding Credentials for ALM..."
/opt/bridge/product/util/opb/credentials_mng_console.sh create -endpoint alm -name ALMNET -user admin -pass Password1

ENTRYPOINTCREDID="$(/opt/bridge/product/util/opb/credentials_mng_console.sh list | grep ID | awk '{ print $3 }')"
SHAREDWORKSPACE="$(cat /opt/octane/conf/sharedspace_logical_name.txt)"
sed -i -e "s,alm-entrypoint-id,$ENTRYPOINTCREDID,g" /tmp/installscripts/json/entrypoint.json

#Authenticate with Octane and save cookies
echo "Authenticating with Octane for API calls for Synchronizer.."
response="$(curl -k --connect-timeout 5 --silent --show-error --cookie-jar headers_and_cookies -w %{http_code} -d "{\"user\": \"$2\", \"password\": \"$3\"}" --header "Content-Type: application/json" $1/authentication/sign_in)"
if [ $? != 0 ]
then
    rm -f headers_and_cookies
    exit $?
fi

response_code="$(echo $response | grep -E -o '.{3}$')"
if [ "$response_code" != "200" ]
then
    echo $response
    rm -f headers_and_cookies
    exit 1
fi

#Create Entrypoint to ALM
echo "Creating entrypoint to ALM..."
response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/entrypoint.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/opb/endpoints)"

if [ $? != 0 ]
then
    rm -f headers_and_cookies
    exit $?
fi

response_code="$(echo $response | grep -E -o '.{3}$')"
if [ "$response_code" != "200" ]
then
    echo $response
    rm -f headers_and_cookies
    exit 1
fi

#Create Defect Link to ALM
echo "Create Defect Link to ALM..."
response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/defect_link.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/sync-links)"

if [ $? != 0 ]
then
    rm -f headers_and_cookies
    exit $?
fi

response_code="$(echo $response | grep -E -o '.{3}$')"
if [ "$response_code" != "200" ]
then
    echo $response
    rm -f headers_and_cookies
    exit 1
fi

#Create Releases Link to ALM
echo "Create Releases Link to ALM..."
response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/releases_link.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/sync-links)"

if [ $? != 0 ]
then
    rm -f headers_and_cookies
    exit $?
fi

response_code="$(echo $response | grep -E -o '.{3}$')"
if [ "$response_code" != "200" ]
then
    echo $response
    rm -f headers_and_cookies
    exit 1
fi

#Create Requirements Link to ALM
echo "Create Requirements Link to ALM..."
response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/requirements_link.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/sync-links)"

if [ $? != 0 ]
then
    rm -f headers_and_cookies
    exit $?
fi

response_code="$(echo $response | grep -E -o '.{3}$')"
if [ "$response_code" != "200" ]
then
    echo $response
    rm -f headers_and_cookies
    exit 1
fi


rm -f headers_and_cookies