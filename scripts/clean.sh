#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# import variables
#cd ~
source ./scripts/variables.sh
source ./scripts/utils.sh

e_timestamp "Entering to $0 $1"
## Iterate through command line parameters
while :
do
  case "$1" in
    -ca | --clean-all)  
      export CLEAN_CONFIG=true
      export CLEAN_BUILD=true
      export CLEAN_DOCKER=true
      break;;  
    -cb | --clean-build)  
      CLEAN_BUILD=true
      break;;      
    -cc | --clean-config) 
      CLEAN_CONFIG=true
      break;;
    -cd | --clean-docker) 
      CLEAN_DOCKER=true
      break;;
    -*)
      e_error "Error: Unknown option: $1" >&2
      exit 1;;
    *)
    break;;				
  esac
done

#echolog "$CLEAN_CONFIG $CLEAN_BUILD $CLEAN_DOCKER"
#clean config
if [[ -n $CLEAN_CONFIG ]]; then
  rm -f $BUILD_DIR/.config
  e_success "BUILD_DIR/.config erased $?"
fi		

#clean build
if [[ -n $CLEAN_BUILD ]]; then
  #remove all files, include hidden files, no prompt
  #rm -rf $BUILD_DIR/{*,.*}
  rm -rf $BUILD_DIR/
  e_success "BUILD_DIR erased $?"
fi

#clear docker
if [[ -n $CLEAN_DOCKER ]]; then
  # check for running docker
  if ! docker info > /dev/null 2>&1; then
    e_error "Docker is missing..."
    e_error "This script uses docker, and if it isn't running - please start docker and try again!"
    exit 1
  fi
  # part no.3 todo reusing docker proces
  # zisti ci kontajner je spusteny, ak nie spusti ho
  DOCKER_CONTAINER_ID=$( docker ps --format "{{.ID}}" --filter ancestor=$DOCKER_CONTAINER_NAME )
  if [[ -n $DOCKER_CONTAINER_ID ]]; then
    if [ "$( docker container inspect -f '{{.State.Status}}' $DOCKER_CONTAINER_NAME )" == "running" ]; then 
      e_error "coreboot_sdk is not running..."
    else
      e_success "coreboot_sdk container is running, container ID: $DOCKER_CONTAINER_ID"
      docker stop $DOCKER_CONTAINER_ID
    fi		
  else
    e_error "docker container coreboot_sdk is not running"
  fi
  # check if docker image coreboot-sdk is created
  # DOCKER_IMAGE_ID=$( docker images --format "{{.ID}}" --filter=reference=$DOCKER_CONTAINER_NAME )
  # check for WORKER_DIR
  if [[ ! -d $WORKER_DIR ]]; then
    e_error "WORKER_DIR is not present"
  else
    e_note "deleting WORKER_DIR"
    rm -rf $WORKER_DIR
    e_success "WORKER_DIR erased $?"
  fi
  # check for existing docker image
  if [[ -n $DOCKER_IMAGE_ID ]]; then
    docker rmi -f $DOCKER_IMAGE_ID
    e_success "DOCKER_IMAGE erased, id: $DOCKER_IMAGE_ID, status $?"
    docker system prune -f
    e_note "$?"
  else
    e_note "there is not coreboot_sdk image to erase"
  fi
fi

exit 0
