#!/usr/bin/env bash

export MY_APP=${args[0]}

#always build the linux executable for the docker container. Optionally build a local version
if [ "$(uname)" == "Darwin" ]; then
    echo "mac detected"
    dep ensure -update
    env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags "-s -w" -a -installsuffix nocgo -o bin/$MY_APP.darwin .
    env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -a -installsuffix nocgo -o bin/$MY_APP.linux.amd64 .
    # make executable
    chmod 755 bin/$MY_APP.*
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Linux detected"
    bin/dep-windows-amd64.exe ensure -update
    env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -a -installsuffix nocgo -o bin/$MY_APP.linux.amd64 .
    # make executable
    chmod 755 bin/$MY_APP.*
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    echo "ming32 detected"
    bin/dep-windows-amd64.exe ensure -update
    env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -a -installsuffix nocgo -o bin/$MY_APP.linux.amd64 .
    # make executable
    chmod 755 bin/$MY_APP.*
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    echo "ming64 detected"
    bin/dep-windows-amd64.exe ensure -update
    env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags "-s -w" -installsuffix nocgo -o bin/$MY_APP.linux.amd64 .
    # make executable
    chmod 755 bin/$MY_APP.*
elif [ "$(expr substr $(uname -s) 1 5)" == "raspberrypi" ]; then
    echo "raspberrypi detected"
    dep ensure -update
    env CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -ldflags "-s -w" -a -installsuffix nocgo -o bin/$MY_APP.pi .
    # make executable
    chmod 755 bin/$MY_APP.*
elif [ -z "$HOME"]; then
    # we must be in windows?
    echo "windows assumed"
    bin/dep-windows-amd64.exe ensure -update
    env CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -a -installsuffix nocgo -o bin/$MY_APP.exe .
    env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix nocgo -o bin/$MY_APP.linux.amd64 .
fi
