# 1 - Connect Grafana to InfluxDB to show Jenkins stats

## Step 1 - Stand up and connect Grafana

This step is fairly straight forward. First stand up Grafana and connect it to the existing Docker network

```
docker run -d --name=grafana --net=influxdb -p 3000:3000  grafana/grafana
```

Once its running, visit localhost:3000 and config Grafana to communicate with our influxDB instance.

![alt text](https://github.com/peterlamar/influxops/blob/master/img/grafanaconfig.png "Grafana influxdb config")

## Step 2 - Create a dashboard

Next, configure a straight forward dashboard to get started with Jenkins statistics. 

![alt text](https://github.com/peterlamar/influxops/blob/master/img/grafanajenkinsdash.png "Grafana jenkins config")
