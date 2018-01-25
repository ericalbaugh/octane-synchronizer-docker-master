#!/bin/bash

/startup/oracle_start.sh
/opt/octane/wrapper/HPALM start
/usr/share/elasticsearch/bin/elasticsearch -Des.insecure.allow.root=true -p /tmp/elasticsearch-pid &

# Check to see if Octane is up: Use -L to redirect to actual URL
while [[ $(curl -L -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do
  echo "Waiting 30 seconds for Octane startup"
  sleep 30
done