#!/bin/bash
if [ "$1" = "" ] | [ "$2" = "" ] | [ "$3" = "" ]
then
    echo usage: configure_bridge_links.sh \<octane-url:port\> \<sa_username\> \<password\>
    echo example: configure_bridge_links.sh http://octance-server.com:8080 sa@octane.com P@ssWord
    exit 2
fi

cd /tmp

SHAREDWORKSPACE="$(cat /opt/octane/conf/sharedspace_logical_name.txt)"

#Authenticate with Octane and save cookies
echo "Authenticating with Octane for API calls for user creation and mapping..."
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

#Add users to Octane
echo "Adding users to Octane..."
response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/users.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/users)"

if [ $? != 0 ]
then
    rm -f headers_and_cookies
    exit $?
fi

response_code="$(echo $response | grep -E -o '.{3}$')"
if [ "$response_code" != "201" ]
then
    echo $response
    rm -f headers_and_cookies
    exit 1
fi

#Adding CI Users
#echo "Adding CI Users to Octane..."
#response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Content-Type: application/json" -H "HPECLIENTTYPE: HPE_MQM_UI" $1/internal-api/shared_spaces/1001/workspaces/1002/analytics/ci/data_population/mock_ci_execution)"
#
#if [ $? != 0 ]
#then
#    rm -f headers_and_cookies
#    exit $?
#fi
#
#response_code="$(echo $response | grep -E -o '.{3}$')"
#if [ "$response_code" != "200" ]
#then
#    echo $response
#    rm -f headers_and_cookies
#    exit 1
#fi

##Mapping users to Octane
#echo "Mapping users to ALM..."
response="$(curl -X POST -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/user-mapping.json  -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8"  http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/manual-user-mapping)"

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