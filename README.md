# influxops (TIG Stack)

Here are the basics to get a local Telegraph, InfluxDB, Jenkins and Grafana running together. This is affectionately named the 'TIG' or Telegraph, InfluxDB and Grafana stack. 

# 1 - Run and connect components locally

## Step 1a - Docker commands

Step 1 is to get the components running locally in the simplest manner possible.
This is not a production configuration but rather steps to follow to fully
understand a topic.

This can be done with docker and a few quick commands.

First we create a [docker network](https://docs.docker.com/network/) for the components to communicate with eachother

```bash
docker network create influxdb
```

Then we standup [influxdb](https://github.com/influxdata/influxdb) on the network

```bash
docker run -d --name=influxdb --net=influxdb -p 8086:8086 influxdb
```

Next [chronograf](https://github.com/influxdata/chronograf) As a visualization on influxdb

```bash
docker run -d -p 8888:8888 --net=influxdb chronograf --influxdb-url=http://influxdb:8086
```

Finally Jenkins, so that we may consume events and display them

```bash
docker run -d -p 8080:8080 --net=influxdb -p 50000:50000 jenkins/jenkins:latest
```

Or if you like, trigger the shell script that performs all these steps

```bash
./influxjenkinschronoup.sh
```

These commands create a [docker network](https://docs.docker.com/network/). The network is a bridge network, a local address space of 172.18.0.0/16, that allows the different components to find
the influxDB ip address http://influxdb:8086, which is routed to a dynamic local assigned address of which http://172.10.0.2:8086 is an example.

Passing in -p commands allows the containers to also be accessed with localhost:8086 for in-browser debugging.

## Step 1b - Install Jenkins plugin(s)

Next the [influxDB plugin](https://wiki.jenkins.io/display/JENKINS/InfluxDB+Plugin) for Jenkins will be required. Install it on the running Jenkins and the configure it to work with your local influxDB instance.

![alt text](https://github.com/peterlamar/influxops/blob/master/img/influxconfig.png "Jenkins influxDB config")


Next install any required tools to run your specific project. I use a golang example so I had to install the [go plugin](https://wiki.jenkins.io/display/JENKINS/Go+Plugin) and configure it in the [manage jenkins/tools](https://www.safaribooksonline.com/library/view/devops-bootcamp/9781787285965/b02a0f03-339c-4243-ac0c-1d9d2ab6af4a.xhtml) section.

## Step 1c - Run a pipeline and check the stats in influxDB

Either point jenkins to a working repo + jenkinsfile or paste the following code in the pipeline text to get it up and running.

```
pipeline {
    agent any

    stages {
        stage('Build Bin') {
            steps {
                echo 'Building Bin'
            }
        }
        stage('Build War') {
            steps {
                echo 'Building War'
            }
        }
    }

    post {
        always {
            echo 'This will always run'
            emailext body:  "Build URL: ${BUILD_URL}",
                subject: "$currentBuild.currentResult-$JOB_NAME",
                to: 'peter.lamar@optum.com'
            step([$class: 'InfluxDbPublisher',
                    customData: null,
                    customDataMap: null,
                    customPrefix: null,
                    target: 'influxDB'])
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
```


# 2 - Connect Grafana to InfluxDB to show Jenkins stats

## Step 2a - Stand up and connect Grafana

This step is fairly straight forward. First stand up Grafana and connect it to the existing Docker network

```bash
docker run -d --name=grafana --net=influxdb -p 3000:3000  grafana/grafana
```

Or shell script with this step

```
./graphanaup.sh
```

Once its running, visit localhost:3000 and config Grafana to communicate with our influxDB instance.

![alt text](https://github.com/peterlamar/influxops/blob/master/img/grafanaconfig.png "Grafana influxdb config")

## Step 2b - Create a dashboard

Next, configure a straight forward dashboard to get started with Jenkins statistics. 

![alt text](https://github.com/peterlamar/influxops/blob/master/img/grafanajenkinsdash.png "Grafana jenkins config")

Congratulations, you have the cluster running!

## Cleanup, if desired

Stop all local containers: 

```
docker kill $(docker ps -q)
```

Delete all local containers: 

```
docker rm $(docker ps -a -q)
```

Delete all images: 
```
docker rmi $(docker images -q)
```
