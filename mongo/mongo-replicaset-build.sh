#!/bin/bash

if [ $(id -u) -ne 0 ]
then echo "Please run this script as root"
        exit
fi

mkdir -p /data/db{1..3}
mkdir -p /data/log/db/

chown -R mongodb:mongodb /data/*

mongod --port 27017 --dbpath /data/db1 --replSet rs0 --fork --logpath /data/log/db/mongod1.log
mongod --port 27018 --dbpath /data/db2 --replSet rs0 --fork --logpath /data/log/db/mongod2.log
mongod --port 27019 --dbpath /data/db3 --replSet rs0 --fork --logpath /data/log/db/mongod3.log

