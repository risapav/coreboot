#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# part no.1
# check for running docker
if ! docker info > /dev/null 2>&1; then
  echo "Docker is missing..."
  echo "This script uses docker, and if it isn't running - please start docker and try again!"
  exit 1
fi

# part no.2
# check if docker image coreboot-sdk is created
DOCKER_IMAGE_ID=$( docker images --format "{{.ID}}" --filter=reference=$DOCKER_CONTAINER_NAME )

if [[ -z $DOCKER_IMAGE_ID ]]; then
  # Coreboot
  if [[ ! -d $WORKER_DIR ]]; then
    printf "Downloading Coreboot\n"
    git clone --recursive $COREBOOT_SDK_REPOSITORY $WORKER_DIR
  else
    printf "Coreboot repository is already present\n"
  fi

  # coreboot-sdk is necessary to create
  docker build $WORKER_DIR -t $DOCKER_CONTAINER_NAME --build-arg BUILD_DIR=$BUILD_DIR --build-arg COREBOOT_SDK_TAG=$COREBOOT_SDK_TAG --build-arg ARCH=$ARCH
  if [[ $? -ne 0  ]]; then
    echo "Docker image $DOCKER_CONTAINER_NAME can not create..."
    exit 1
  fi
  echo "Docker image $DOCKER_CONTAINER_NAME is ready to use "
fi

# part no.3 todo reusing docker proces
# zisti ci kontajner je spusteny, ak nie spusti ho
DOCKER_CONTAINER_ID=$( docker ps --format "{{.ID}}" --filter ancestor=$DOCKER_CONTAINER_NAME )

if [ "$( docker container inspect -f '{{.State.Status}}' $DOCKER_CONTAINER_NAME )" == "running" ]; then 
  echo "coreboot_sdk is not running..."
  echo $DOCKER_CONTAINER_ID
fi

exit 0
