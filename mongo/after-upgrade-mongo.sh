#!/bin/bash


if [ "$EUID" -ne 0 ] 
	then echo "Run this script as root user"
	exit
fi

upgraded_version=4.0.28

mongod_ips=$(lsof -nP -iTCP -sTCP:LISTEN | grep mongod | awk '{print $9}' | xargs -I % echo 'mongodb://%')

mongod_ips_array=($mongod_ips)

for ip in "${mongod_ips_array[@]}"; do

	version=$(mongo "$ip" --eval "print(db.version())" --quiet)

	if [ $version != $upgraded_version ]
	then 
		echo "Upgrade of replica on ip $ip failed"
	else 
		echo "Upgrade of replica on ip $ip succedeed"
	fi
done

