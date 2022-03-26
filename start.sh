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

set -E

spin() {
  sp='/-\|'
  i=0
  printf ' '
  sleep 0.5
  while [ "$i" -lt 120 ]; do
    printf '\b%.1s' "$sp"
    sp=${sp#?}${sp%???}
    i=$((i+1))
    sleep 0.5
  done
}

stop_container() {
  if docker container ls | grep $SERV_NAME > /dev/null 2>&1; then
    echo "Stopping current container..."
    docker container stop $SERV_NAME > /dev/null 2>&1
  fi
}

if [ $REBUILD -eq 1 ]; then
  if docker image ls | grep $IMG_NAME > /dev/null 2>&1; then
    echo "Removing existing $IMG_NAME image..."
    docker image rm $IMG_NAME
  fi
fi

if ! docker image ls | grep $IMG_NAME > /dev/null 2>&1; then
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

stop_container
printf "Starting $SERV_NAME container... "

if [ "$DEVMODE" -eq 1 ]; then

  docker run -it --rm \
    --name $SERV_NAME \
    --hostname $HOST_NAME \
    --mount type=bind,source=$(pwd)/app,target=/root/app \
    --mount type=bind,source=$(pwd)/files,target=/root/files \
    --mount type=volume,source=$SERV_NAME-data,target=/root/data \
    --entrypoint bash \
  $IMG_NAME:$IMG_VER

else

  CONT_ID=$(docker run -d --rm \
    --name $SERV_NAME \
    --hostname $HOST_NAME \
    --mount type=bind,source=$(pwd)/app,target=/root/app \
    --mount type=bind,source=$(pwd)/files,target=/root/files \
    --mount type=volume,source=$SERV_NAME-data,target=/root/data \
  $IMG_NAME:$IMG_VER)

  ONION_ADDR=""
  TIMEOUT=0
  spin & spinpid=$!

  while [ -z "$ONION_ADDR" ]; do
    if [ "$TIMEOUT" -gt 30 ]; then
      kill "$spinpid"
      printf "\nFailed to get onion address: Timed out.\n"
      stop_container
      exit 1
    fi
    ONION_ADDR=$(docker container logs --tail 5 $CONT_ID | grep "onion address")
    TIMEOUT=$((TIMEOUT+1))
    sleep 1
  done

  kill "$spinpid"
  printf "\n$SERV_NAME running with $ONION_ADDR\n"

fi
