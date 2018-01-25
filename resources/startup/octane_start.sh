#!/bin/bash

if [[ -z $OCTANE_HOST ]]; then
    export OCTANE_HOST=nimbusserver.aos.com
fi

echo Setting Octane Host to $OCTANE_HOST

sed -i -e "s,SSO_Redirect_To_AuthPage_Url,http://$OCTANE_HOST:8085/authentication-point/web-ui-login.jsp,g" /opt/sync/conf/sync.yml
sed -i -e "s,Sso_Master_LoginUrl,http://$OCTANE_HOST:8085/authentication-point/web-ui-login.jsp,g" /opt/sync/conf/sync.yml
sed -i -e "s,Sso_Master_LogoutUrl,http://$OCTANE_HOST:8085/authentication-point/sign_out.jsp,g" /opt/sync/conf/sync.yml

sed -i -e "s,SSO_Redirect_To_AuthPage_Url,http://$OCTANE_HOST:8085/authentication-point/web-ui-login.jsp,g" /opt/ibs/conf/ibs.yml
sed -i -e "s,Sso_Master_LoginUrl,http://$OCTANE_HOST:8085/authentication-point/web-ui-login.jsp,g" /opt/ibs/conf/ibs.yml
sed -i -e "s,Sso_Master_LogoutUrl,http://$OCTANE_HOST:8085/authentication-point/sign_out.jsp,g" /opt/ibs/conf/ibs.yml

sed -i -e 's,#SYNC_BASE_URL,SYNC_BASE_URL,g' /opt/sync/conf/octane.site.params.properties
sed -i -e "s,sync-server.company.net:8080,$OCTANE_HOST:9082,g" /opt/sync/conf/octane.site.params.properties
sed -i -e 's/#EXTERNAL_HELP_URL/EXTERNAL_HELP_URL/g' /opt/sync/conf/octane.site.params.properties
sed -i -e "s,octane-server.company.net:8080,$OCTANE_HOST:8085,g" /opt/sync/conf/octane.site.params.properties

sed -i -e 's,#IBS_BASE_URL,IBS_BASE_URL,g' /opt/sync/conf/sync.site.params.properties
sed -i -e "s,ibs-server.company.com:8080,$OCTANE_HOST:9081,g" /opt/sync/conf/sync.site.params.properties

/startup/oracle_start.sh
/opt/octane/wrapper/HPALM start
/opt/ibs/wrapper/HPEOctaneIBS start
/opt/sync/wrapper/HPEOctaneSync start
/usr/share/elasticsearch/bin/elasticsearch -Des.insecure.allow.root=true &

# Check to see if Octane is up: Use -L to redirect to actual URL
while [[ $(curl -L -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do
  echo "Octane starting up..."
  sleep 20
done

/opt/bridge/product/bin/StartHPEIntegrationBridge.sh

/opt/sync/install/set-site-parameters-to-octane.sh http://octane.aos.com:8080 sa@nga Password1 /opt/sync/conf/octane.site.params.properties

tail -f opt/octane/log/wrapper.log




