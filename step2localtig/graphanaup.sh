#!/bin/bash

docker run -d --name=grafana --net=influxdb -p 3000:3000  grafana/grafana
