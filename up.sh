#!/bin/bash

docker run -d --name=influxdb --net=influxdb -p 8086:8086 influxdb
docker run -p 8888:8888 --net=influxdb chronograf --influxdb-url=http://influxdb:8086
