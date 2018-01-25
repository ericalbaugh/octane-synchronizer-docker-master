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

#Run Integrity Check for Defects Link
echo "Run Integrity Check for Defects Link to ALM..."
response="$(curl -X GET -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/integrity-check?link-id=1)"

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

RUNID="$(echo $response | grep -Po '"runId": *\K[^"]*}' | tr -d '}')"

INTEGRITYSTATUS="RUNNING"
echo "Check Defects Link Integrity Status..."
while [[ $INTEGRITYSTATUS == "RUNNING" ]]
do

sleep 5
response="$(curl -X GET -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/run-progress?run-id=$RUNID)"

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

INTEGRITYSTATUS="$(echo $response | grep -Po '"currentStatus": *\K"[^"]*"' | tr -d '"')"
echo $INTEGRITYSTATUS
done


#Run Integrity Check for Releases Link
echo "Run Integrity Check for Releases Link to ALM..."
response="$(curl -X GET -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/integrity-check?link-id=2)"

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

RUNID="$(echo $response | grep -Po '"runId": *\K[^"]*}' | tr -d '}')"

INTEGRITYSTATUS="RUNNING"
echo "Check Releases Link Integrity Status..."
while [[ $INTEGRITYSTATUS == "RUNNING" ]]
do

sleep 5
response="$(curl -X GET -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/run-progress?run-id=$RUNID)"

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

INTEGRITYSTATUS="$(echo $response | grep -Po '"currentStatus": *\K"[^"]*"' | tr -d '"')"
echo $INTEGRITYSTATUS
done

#Run Integrity Check for Requirements Link
echo "Run Integrity Check for Requirements Link to ALM..."
response="$(curl -X GET -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/integrity-check?link-id=3)"

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

RUNID="$(echo $response | grep -Po '"runId": *\K[^"]*}' | tr -d '}')"

INTEGRITYSTATUS="RUNNING"
echo "Check Requirements Link Integrity Status..."
while [[ $INTEGRITYSTATUS == "RUNNING" ]]
do
sleep 5
response="$(curl -X GET -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies -H "Accept: application/json; schema=alm-web; charset=UTF-8" -H "Content-Type: application/json; schema=alm-web; charset=UTF-8" http://octane.aos.com:9082/sync/api/shared_spaces/$SHAREDWORKSPACE/run-progress?run-id=$RUNID)"

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

INTEGRITYSTATUS="$(echo $response | grep -Po '"currentStatus": *\K"[^"]*"' | tr -d '"')"
echo $INTEGRITYSTATUS
done

rm -f headers_and_cookies
