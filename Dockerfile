ARG OCTANE
FROM admpresales/octane:$OCTANE

ARG OCTANE_REPO="ftp://hpeadm:wp+MN2gd@ftp.ext.hpe.com/Binaries/Octane"
ARG OCTANE_BRIDGE
ARG OCTANE_SYNC

LABEL authors="Bryan Cole,Jason Hrabi"
LABEL description="Nimbus Octane Bridge"

ENV OCTANE_BRIDGE=${OCTANE_BRIDGE} \
    OCTANE_SYNC=${OCTANE_SYNC}
ENV OCTANE_SYNC_URL=${OCTANE_REPO}/octane-synchronizer-${OCTANE_SYNC}.tar.gz \
    OCTANE_BRIDGE_URL=${OCTANE_REPO}/octane-integration-bridge-service-${OCTANE_BRIDGE}.tar.gz

RUN cd /opt \
    && curl -s -q -g ${OCTANE_SYNC_URL}  | tar xvz \
    && curl -s -q -g ${OCTANE_BRIDGE_URL} | tar xvz \
    && chown octane:octane -R /opt/ibs \
    && chown octane:octane -R /opt/sync \
    && yum install -q -y unzip \
    && yum clean all

RUN sed -i -e 's,IBS_Url,http://octane.aos.com:9081/opb,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,SYNC_Url,http://octane.aos.com:9082/sync,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,Octane_Url,http://octane.aos.com:8080,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,EncryptionSeed_String,Password1,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,Log_Folder,/opt/ibs/logs,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,Service_Port,9081,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_Action,CREATE_NEW,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_Type,ORACLE,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_Connection_String,jdbc:mercury:oracle://octane.aos.com:1521;servicename=XE,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_AdminUser,system,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_AdminPassword,Password1,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_Schema_Name,ibs_sa,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_SA_Schema_Password,Password1,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_Tablespace,USERS,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,DB_Temp_Tablespace,TEMP,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,Repository_Folder,/opt/ibs/repo,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,hazelcastpw,Password1,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,Hazelcast_Port,5791,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,SSO_Init_String,Password1,g' /opt/ibs/conf/ibs.yml \
    && sed -i -e 's,Sso_Master_Domain,aos.com,g' /opt/ibs/conf/ibs.yml

RUN cp /opt/octane/webapps/service.locator.properties.example /opt/octane/webapps/service.locator.properties \
    && chown octane:octane /opt/octane/webapps/service.locator.properties \
    && sed -i -e 's/<Synchronizer service location>:8082/octane.aos.com:9082/g' /opt/octane/webapps/service.locator.properties \
    && sed -i -e 's/<Integration Bridge service location>:8081/octane.aos.com:9081/g' /opt/octane/webapps/service.locator.properties \
    && sed -i -e 's/<Octane server location>:8080/octane.aos.com:8080/g' /opt/octane/webapps/service.locator.properties

RUN sed -i -e 's/#wrapper.java.additional.38/wrapper.java.additional.38/g' /opt/octane/wrapper/wrapper.conf \
    && sed -i -e 's/#wrapper.java.additional.39/wrapper.java.additional.39/g' /opt/octane/wrapper/wrapper.conf

RUN sed -i -e 's,IBS_Url,http://octane.aos.com:9081/opb,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,SYNC_Url,http://octane.aos.com:9082/sync,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,Octane_Url,http://octane.aos.com:8080,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,EncryptionSeed_String,Password1,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,Log_Folder,/opt/sync/logs,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,Service_Port,9082,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_Action,CREATE_NEW,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_Type,ORACLE,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_Connection_String,jdbc:mercury:oracle://octane.aos.com:1521;servicename=XE,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_AdminUser,system,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_AdminPassword,Password1,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_Schema_Name,synca_sa,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_SA_Schema_Password,Password1,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_Tablespace,USERS,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,DB_Temp_Tablespace,TEMP,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,Repository_Folder,/opt/sync/repo,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,hazelcastpw,Password1,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,Hazelcast_Port,5792,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,SSO_Init_String,Password1,g' /opt/sync/conf/sync.yml \
    && sed -i -e 's,Sso_Master_Domain,aos.com,g' /opt/sync/conf/sync.yml

COPY /resources/installscripts /tmp/installscripts
COPY /resources/startup /startup

RUN chmod 774 /tmp/installscripts/* && sleep 1 \
    && /tmp/installscripts/add_octane_host.sh \
    && /tmp/installscripts/octane_prepare.sh \
    && /tmp/installscripts/add_integration_info.sh \
    && export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") \
    && /opt/ibs/install/install.sh \
    && /opt/sync/install/install.sh \
    && /opt/ibs/wrapper/HPEOctaneIBS start \
    && /opt/sync/wrapper/HPEOctaneSync start \
    && /tmp/installscripts/run_api_commands.sh octane.aos.com:8080 sa@nga Password1 \
    && echo "wrapper.java.additional.204=-Dexecutor.site.version.validation.required=N" >> /opt/bridge/product/conf/wrapper-custom.conf \
    && /opt/bridge/product/bin/StopHPEIntegrationBridge.sh \
    && /opt/bridge/product/bin/StartHPEIntegrationBridge.sh \
    && /tmp/installscripts/configure_bridge_links.sh octane.aos.com:8080 sa@nga Password1 \
    && /tmp/installscripts/run_integrity_checks.sh octane.aos.com:8080 sa@nga Password1 \
    && /tmp/installscripts/add_users.sh octane.aos.com:8080 sa@nga Password1 \
    && /opt/bridge/product/bin/StopHPEIntegrationBridge.sh \
    && /opt/ibs/wrapper/HPEOctaneIBS stop \
    && /opt/sync/wrapper/HPEOctaneSync stop \
    && /opt/octane/wrapper/HPALM stop \
    && chown -R octane:octane /opt/octane \
    && /tmp/installscripts/cleanup.sh \
    && rm -f /opt/octane/log/wrapper.log \
    && rm -rf /tmp/* \
    && chmod 774 -R /startup

COPY resources/aob.json /opt/octane/webapps/root/ui/platform/data-populator/data

RUN gzip -f /opt/octane/webapps/root/ui/platform/data-populator/data/aob.json










