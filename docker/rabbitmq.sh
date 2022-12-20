#!/bin/bash
read -p "Enter vhost name: " vhostName
read -p "Enter queue name: " queueName

containerName=predictions-rabbitmq

isUp="docker ps -a | grep $containerName | wc -l"
isRunning="docker ps | grep $containerName | wc -l"

docker_run="docker run -d --name $containerName -p 15672:15672 -p 5672:5672 rabbitmq:3-management"
docker_start="docker start $containerName"
rabbit_status="docker exec $containerName rabbitmqctl status"
status=$($rabbit_status 2>&1 | grep -q "Error")

if [ $(eval $isUp) -eq 0 ]; then
	echo "RabbitMQ container is not running. Starting container..."
	$docker_run
	echo "Waiting for RabbitMQ container to start..."
	for i in {1..10}; do
		sleep 1
		if [ $(eval $isRunning) -eq 1 ]; then
			break
		fi
	done
fi

if [ $(eval $isRunning) -eq 0 ] || $status; then
	$docker_start
	for i in {1..10}; do
		if $($rabbit_status 2>&1 | grep -q "Status of node rabbit@"); then
			echo "RabbitMQ node is running."
			break
		fi
		echo "Waiting for RabbitMQ node to start..."
		sleep 1
	done
fi

script="
	#!/bin/bash
	vhostName=$vhostName 
	queueName=$queueName 
	rabbitmqctl add_vhost $vhostName 
	rabbitmqctl set_permissions -p $vhostName guest \".*\" \".*\" \".*\"
	rabbitmqadmin -u guest -p guest -V $vhostName declare queue name=$queueName
"
docker exec $containerName bash -c "echo -e $script"
