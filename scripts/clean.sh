#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# import variables
source ./scripts/variables.sh

echolog "entering to $0 $1"
## Iterate through command line parameters
while :
do
    case "$1" in
      -cb | --clean-build)  
				rm -rf $BUILD_DIR/*
				echolog "$BUILD_DIR erased $?"
        exit 0;;      
      -cc | --clean-config) 
				rm -y $BUILD_DIR/.config
				echolog "$BUILD_DIR/.config erased $?"
        exit 0;;
      -cd | --clean-docker) 
				# check for running docker
				if ! docker info > /dev/null 2>&1; then
					echolog "Docker is missing..."
					echolog "This script uses docker, and if it isn't running - please start docker and try again!"
					exit 1
				fi
				# part no.3 todo reusing docker proces
				# zisti ci kontajner je spusteny, ak nie spusti ho
				DOCKER_CONTAINER_ID=$( docker ps --format "{{.ID}}" --filter ancestor=$DOCKER_CONTAINER_NAME )
				if [[ -n $DOCKER_CONTAINER_ID ]]; then
					if [ "$( docker container inspect -f '{{.State.Status}}' $DOCKER_CONTAINER_NAME )" == "running" ]; then 
						echolog "coreboot_sdk is not running..."
					else
						echolog "coreboot_sdk container is running, container ID: $DOCKER_CONTAINER_ID"
						docker stop $DOCKER_CONTAINER_ID
					fi		
				else
					echolog "docker container coreboot_sdk is not running"
				fi
				# check if docker image coreboot-sdk is created
				DOCKER_IMAGE_ID=$( docker images --format "{{.ID}}" --filter=reference=$DOCKER_CONTAINER_NAME )
				# check for WORKER_DIR
				if [[ ! -d $WORKER_DIR ]]; then
					echolog "WORKER_DIR is not present"
				else
					echolog "deleting WORKER_DIR"
					rm -rf $WORKER_DIR
					echolog "WORKER_DIR erased $?"
				fi
				# check for existing docker image
				if [[ -n $DOCKER_IMAGE_ID ]]; then
					docker rmi -f $DOCKER_IMAGE_ID
					echolog "DOCKER_IMAGE erased, id: $DOCKER_IMAGE_ID, status $?"
					docker system prune
					echolog "$?"
				else
				  echolog "there is not coreboot_sdk image to erase"
				fi
        exit 0;;
      -*)
        echolog "Error: Unknown option: $1" >&2
        exit 1;;
      *)
        break;;				
			esac
done

exit 0