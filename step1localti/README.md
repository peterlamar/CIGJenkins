# 1 - Run and connect components locally

## Step 1 - Docker commands

Step 1 is to get the components running locally in the simplest manner possible.
This is not a production configuration but rather steps to follow to fully
understand a topic.

This can be done with docker and a few quick commands.

```
docker network create influxdb
docker run -d --name=influxdb --net=influxdb -p 8086:8086 influxdb
docker run -d -p 8888:8888 --net=influxdb chronograf --influxdb-url=http://influxdb:8086
docker run -d -p 8080:8080 --net=influxdb -p 50000:50000 -v /home/plamar/dev/jenkins:/var/jenkins_home jenkins/jenkins:latest

```

These commands create a [docker network](https://docs.docker.com/network/). The network is a bridge network, a local address space of 172.18.0.0/16, that allows the different components to find
the influxDB ip address http://influxdb:8086, which is routed to a dynamic local assigned address of which http://172.10.0.2:8086 is an example.

Passing in -p commands allows the containers to also be accessed with localhost:8086 for in-browser debugging.

## Step 2 - Install Jenkins plugin(s)

Next the [influxDB plugin](https://wiki.jenkins.io/display/JENKINS/InfluxDB+Plugin) for Jenkins will be required. Install it on the running Jenkins and the configure it to work with your local influxDB instance.

Next install any required tools to run your specific project. I use a golang example so I had to install the [go plugin](https://wiki.jenkins.io/display/JENKINS/Go+Plugin) and configure it in the [manage jenkins/tools](https://www.safaribooksonline.com/library/view/devops-bootcamp/9781787285965/b02a0f03-339c-4243-ac0c-1d9d2ab6af4a.xhtml) section.

## Step 3 - Run a pipeline and check the stats in influxDB

Either point jenkins to a working repo + jenkinsfile or paste the following code in the pipeline text to get it up and running.

```
pipeline {
    agent any

    tools {
       go "Go 1.10.2"
    }

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
