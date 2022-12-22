#!/bin/bash

image=timescale/timescaledb:1.6.1-pg11-bitnami
container=timescale-db

isPulled="docker pull $image"
isUp="docker ps | grep $container | wc -l"

if [ "$(docker ps -aq -f name=^/$container$)" ]; then
  echo "TimescaleDB container is already created"
else
  docker run -d --name $container -e POSTGRES_PASSWORD=postgres -p 5432:5432 $image
  until docker exec $container pg_isready 1>/dev/null; do
    echo "TimescaleDB is unavailable - sleeping"
    sleep 1
  done
fi

docker stop $container
docker rm $container

echo >&2 "TimescaleDB is up and running"
until $($isPulled 2>&1 | grep -q "Status: Image is up to date for"); do
  echo "Pulling TimescaleDB image..."
  sleep 1
done
echo "TimescaleDB image is up to date."

until [ $(eval $isUp) -eq 1 ]; do
  echo "Starting TimescaleDB container..."
  docker run -d --name $container -p 5432:5432 $image
  sleep 1
done
echo "TimescaleDB container is running."

docker exec -it $container psql -U postgres -c "CREATE TABLE example (time TIMESTAMPTZ NOT NULL, value INTEGER NOT NULL);"
