#!/bin/bash
if [ "$1" = "" ] | [ "$2" = "" ] | [ "$3" = "" ]
then
    echo usage: generateadminapikey.sh \<octane-url:port\> \<sa_username\> \<password\>
    echo example: generateadminapikey.sh http://octance-server.com:8080 sa@octane.com P@ssWord
    exit 2
fi

cd /tmp

SHAREDWORKSPACE="$(cat /opt/octane/conf/sharedspace_logical_name.txt)"
ALMSECRET="?ed7355849734bdJ"
APISECRET="=73eb49a4f85f725cN"

#Authenticate with Octane and save cookies
echo "Authenticating with Octane for API calls..."
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

#Enable bridge (opb/ibs)
echo "Enable Bridge Service..."
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d '{"data":[{"op":"ENABLE_SERVICE","parameters":{"shared_space_id":"1001","services":["opb"]}}]}' --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/admin/maintenance_tasks)"

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

#Enable synchronizer
echo "Enable Synchronizer Service..."
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d '{"data":[{"op":"ENABLE_SERVICE","parameters":{"shared_space_id":"1001","services":["sync"]}}]}' --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/admin/maintenance_tasks)"

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

#Create ALMNET_Sync API Access
echo "Create ALMNET_Sync API Access key..."
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d '{"data":[{"client_secret":"'"$ALMSECRET"'","workspace_roles":{"data":[{"type":"workspace_role","id":"1003"}]},"name":"ALMNET_Sync"}]}' --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/api_accesses)"

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

ALMCLIENTID="$(echo $response | grep -Po '"client_id": *\K"[^"]*"' | tr -d '"')"
echo $ALMCLIENTID > /opt/octane/apikeys/almapikey.json
echo $ALMSECRET >> /opt/octane/apikeys/almapikey.json

sed -i -e "s,<client_id>,$ALMCLIENTID,g" /tmp/installscripts/bridge-input.txt
sed -i -e "s,<client_secret>,$ALMSECRET,g" /tmp/installscripts/bridge-input.txt
sed -i -e "s,<workspace_id>,$SHAREDWORKSPACE,g" /tmp/installscripts/bridge-input.txt
sed -i -e "s,<workspace_id>,$SHAREDWORKSPACE,g" /tmp/installscripts/server-connection.conf

#Creating Jenkins CI/CD Integration API Key
echo "Creating Jenkins CI/CD Integration API Key"
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/jenkins_integration_api.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/api_accesses)"

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

JENKINSCLIENTID="$(echo $response | grep -Po '"client_id": *\K"[^"]*"' | tr -d '"')"
echo $JENKINSCLIENTID > /opt/octane/apikeys/jenkinsapikey.json
echo $APISECRET >> /opt/octane/apikeys/jenkinsapikey.json

#Creating PPM Integration API Key
echo "Creating PPM Integration API Key"
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/ppm_integration_api.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/api_accesses)"

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

PPMCLIENTID="$(echo $response | grep -Po '"client_id": *\K"[^"]*"' | tr -d '"')"
echo $PPMCLIENTID > /opt/octane/apikeys/ppmapikey.json
echo $APISECRET >> /opt/octane/apikeys/ppmapikey.json

#Creating Bot Integration API Key
echo "Creating Bot Integration API Key"
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/bot_integration_api.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/api_accesses)"

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

BOTCLIENTID="$(echo $response | grep -Po '"client_id": *\K"[^"]*"' | tr -d '"')"
echo $BOTCLIENTID > /opt/octane/apikeys/botapikey.json
echo $APISECRET >> /opt/octane/apikeys/botapikey.json

#Add Jenkins CI Server
echo "Adding Jenkins CI Server..."
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/ci_server.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/workspaces/1002/ci_servers)"

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

#Accept License Agreement
echo "Accepting License Agreement..."
response="$(curl -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d @/tmp/installscripts/json/accept_license.json --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/workspaces/1002/user_settings)"

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

#Get Synchronizer admin access
echo "Setting Synchronizer Admin permissions on default workspace"
response="$(curl -X PUT -k --connect-timeout 5 --silent --show-error -w %{http_code} --cookie headers_and_cookies  -d '{"workspace_roles":{"data":[{"type":"workspace_role","id":"1012"},{"type":"workspace_role","id":"1007"},{"type":"workspace_role","id":"1008"}]},"id":"1001"}' --header "Content-Type: application/json" --header "HPECLIENTTYPE: HPE_MQM_UI" $1/api/shared_spaces/1001/users/1001)"

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

echo "Unzipping Integration Bridge..."
unzip /opt/sync/webapps/sync/WEB-INF/opb_agent/linux/on-prem-bridge-agent.zip -d /tmp
chmod +x /tmp/hpe-integration-bridge.bin

echo "Installing Integration Bridge..."
cp /tmp/installscripts/server-connection.conf /tmp
/tmp/hpe-integration-bridge.bin < /tmp/installscripts/bridge-input.txt

echo "Remove Integration Bridge install files..."
rm /tmp/hpe-integration-bridge.*

rm -f headers_and_cookies