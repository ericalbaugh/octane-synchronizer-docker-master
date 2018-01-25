#!/bin/bash

DOCKERADDRESS="$(tail -1 /etc/hosts | awk '{print $1}')"
echo ${DOCKERADDRESS} octane.aos.com  >> /etc/hosts