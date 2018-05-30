#!/bin/bash

docker network create influxdb
docker run -d --name=influxdb --net=influxdb -p 8086:8086 influxdb
docker run -p 8888:8888 --net=influxdb chronograf --influxdb-url=http://influxdb:8086
docker run -p 8080:8080 -p 50000:50000 -v /home/plamar/dev/jenkins:/var/jenkins_home jenkins
