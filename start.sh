#!/bin/sh
## Startup script for docker container.

###############################################################################
# Environment
###############################################################################

IMG_NAME="tor-fileserver"
IMG_VER="latest"
SERV_NAME=$IMG_NAME
HOST_NAME=$IMG_NAME

VERBOSE=0
REBUILD=0
DEVMODE=0

###############################################################################
# Script
###############################################################################

spin() {
  sp='/-\|'
  printf ' '
  sleep 0.5
  while true; do
    printf '\b%.1s' "$sp"
    sp=${sp#?}${sp%???}
    sleep 0.5
  done
}

if [ $DEVMODE -eq 1 ]; then
  ENTRYPOINT="--entrypoint bash"
else
  ENTRYPOINT=""
fi

if [ $REBUILD -eq 1 ]; then
  if docker image ls | grep $IMG_NAME > /dev/null 2>&1; then
    echo "Removing existing $IMG_NAME image..."
    docker image rm $IMG_NAME
  fi
fi

if ! docker image ls | grep $IMG_NAME; then
  printf "Building $IMG_NAME from dockerfile... "
  if [ $VERBOSE -eq 1 ]; then
    printf "\n"
    docker build --tag $IMG_NAME .
  else
    spin & spinpid=$!
    docker build --tag $IMG_NAME . > /dev/null 2>&1
    kill "$spinpid"
    printf "\n"
  fi
fi

echo "Starting $SERV_NAME container..."
docker run --rm -it \
  --name $SERV_NAME \
  --hostname $HOST_NAME \
  --mount type=bind,source=$(pwd)/app,target=/root/app \
  --mount type=bind,source=$(pwd)/files,target=/root/files \
  --mount type=volume,source=$SERV_NAME-data,target=/root/data \
  $ENTRYPOINT \
$IMG_NAME:$IMG_VER