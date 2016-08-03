#!/bin/bash
if [ -z "$DOCKER_BUILD_OPTS" ] ; then
    docker build -t udiabon/centos-dev-env .
else
    docker build $DOCKER_BUILD_OPTS -t udiabon/centos-dev-env .
fi
