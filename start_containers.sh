#!/bin/bash

#######################################################################
# Creatting the trt-net docker network if it does not exist
#######################################################################

TRT_NET="trt-net"

if ! docker network ls --format '{{.Name}}' | grep -q "^${TRT_NET}$"; then
  docker network create "$TRT_NET"
fi

#######################################################################
# Resetting the docker compose
#######################################################################
xhost +local:docker

docker-compose -f remote-server.yml stop
docker-compose -f desktop-app/trt-env.yml stop

docker-compose -f remote-server.yml up --remove-orphans -d
docker-compose -f desktop-app/trt-env.yml up --remove-orphans -d