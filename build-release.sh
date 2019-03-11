#!/usr/bin/env bash

$MY_NAME="example"

# ------- Do not edit below here -------

mainmenu () {
  echo "This is the awesome build and release script for $MY_NAME"
  echo "Press 1 to build"
  echo "Press 2 to run in docker"
  echo "Press 3 to run in docker"
  echo "Press 4 to deploy"
  echo "Press 5 to update"
  echo "Press q/enter to run away screaming"
  echo "Press 9 to nuke test. Make sure you're shure"
  read  -n 1 -p "Input Selection:" mainmenuinput
  echo
  if [ "$mainmenuinput" = "1" ]; then
            build
        elif [ "$mainmenuinput" = "2" ]; then
            runLocal
        elif [ "$mainmenuinput" = "3" ]; then
            runDocker
        elif [ "$mainmenuinput" = "4" ]; then
            deploy
        elif [ "$mainmenuinput" = "5" ]; then
            update
        else
            exit
        fi
}

build () {
    echo 'cross compiling'
    ./cross-compile.sh $MY_NAME
}

update () {
    echo 'updating'
    go get -a -v -u all
}

runLocal () {
    if [ "$(uname)" == "Darwin" ]; then
        bin/$MY_APP.darwin
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
         bin/$MY_APP.linux.amd64
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        bin/$MY_APP.linux.amd64 
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        bin/$MY_APP.linux.amd64
    elif [ "$(expr substr $(uname -s) 1 5)" == "raspberrypi" ]; then
        bin/$MY_APP.pi
    elif [ -z "$HOME"]; then
        bin/$MY_APP.exe
    fi
}

runDocker () {
    docker-compose build
    docker-compose up
}

deploy () {
    OLD_CONTEXT=`kubectl config current-context`
    kubectl config set current-context gke_craigskelton-com_us-central1-a_cluster-1
    echo 'deploy to kubernetes'
    DOCKER_TAG=`date +"%m-%d-%Y-%H-%M-%S"`
    docker build -t gcr.io/craigskelton-com/EXAMPLE:$DOCKER_TAG .
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
    docker push gcr.io/craigskelton-com/EXAMPLE:$DOCKER_TAG
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
    kubectl apply -f k8s/deployment.yaml
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
    kubectl -n dorkbot set image deployment/EXAMPLE EXAMPLE=gcr.io/craigskelton-com/EXAMPLE:$DOCKER_TAG
    kubectl config set current-context $OLD_CONTEXT
}

while true; do
    mainmenu
done
