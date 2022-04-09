#!/bin/sh

container_id=$(docker ps -f name=mongo-0-a -q)

mongo_script_path=./upgrade-mongo.js

docker cp $mongo_script_path $container_id:/tmp 

docker exec $container_id sh -c "mongo < /tmp/$mongo_script_path"





