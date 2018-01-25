#!/usr/bin/env bash
#Stop Octane
/opt/octane/wrapper/HPALM stop

#Grab PID for elasticsearch and run kill
kill -SIGTERM `cat /tmp/elasticsearch-pid`

#Shutdown Oracle
/bin/su -s /bin/bash oracle -c "$SQLPLUS -s /nolog @$ORACLE_HOME/config/scripts/stopdb.sql"
