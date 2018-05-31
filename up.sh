#!/bin/bash

# Stop Containers: docker kill $(docker ps -q)
# Delete Containers: docker rm $(docker ps -a -q)
# Delete Images: docker rmi $(docker images -q)

docker network create influxdb
docker run -d --name=influxdb --net=influxdb -p 8086:8086 influxdb
docker run -d -p 8888:8888 --net=influxdb chronograf --influxdb-url=http://influxdb:8086
docker run -d -p 8080:8080 --net=influxdb -p 50000:50000 -v /home/plamar/dev/jenkins:/var/jenkins_home jenkins/jenkins:latest
