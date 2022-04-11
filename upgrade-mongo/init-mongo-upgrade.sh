#!/bin/bash

if [ "$EUID" -ne 0 ]
then echo "Run script as root user";
    exit
fi


mongod_hosts=$(lsof -nP -iTCP -sTCP:LISTEN | grep mongod | awk '{print $9}' | xargs -I % echo 'mongodb://%')

mongod_hosts_array=($mongod_hosts)

for ip in "${mongod_hosts_array[@]}"; do
    checkUpgrade=$(mongo "$ip" < "./upgrade-mongo-replset.js")
