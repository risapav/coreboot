#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

source ./common/variables.sh

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

# ak nie, potom vytvorí image cez github
echo $DOCKER_IMAGE_ID

# zisti ci kontajner je spusteny, ak nie spusti ho
DOCKER_CONTAINER_ID=$( docker ps --format "{{.ID}}" --filter ancestor=$DOCKER_CONTAINER_NAME )

if [ "$( docker container inspect -f '{{.State.Status}}' $DOCKER_CONTAINER_NAME )" == "running" ]; then 
	echo "coreboot_sdk is not running..."
	echo $DOCKER_CONTAINER_ID
fi

# part no.3
# entering into docker powered sdk, input is compile script

docker run --rm --privileged \
	-p 4500:4500 \
	-v /dev/bus/usb:/dev/bus/usb \
	-v $PWD:$DOCKER_ROOT_DIR/prj \
	-w $DOCKER_ROOT_DIR \
	$DOCKER_CONTAINER_NAME \
	./prj/common/compile.sh


	
exit 0

# part no.4
#####################
##   Post build    ##
#####################
## copy compilation results to out DIR, save config file
if [ ! -f "$DOCKER_COREBOOT_DIR/build/coreboot.rom" ]; then
	echo "coreboot.rom as output of compile is missing..."
	exit 4;
else
	mkdir -p $DOCKER_ROOT_DIR/prj/out
	mv "$DOCKER_COREBOOT_DIR/build/coreboot.rom" "$DOCKER_ROOT_DIR/prj/out/coreboot.rom"
	mv "$DOCKER_COREBOOT_DIR/build/.config" "$DOCKER_ROOT_DIR/prj/out/coreboot.config"
fi

echo "build.sh is done"
exit 0


# shellcheck disable=SC1091


exit

source /home/coreboot/common_scripts/./download_coreboot.sh
source /home/coreboot/common_scripts/./config_and_make.sh


################################################################################
## MODEL VARIABLES
################################################################################
MAINBOARD="lenovo"
MODEL="t410"

STOCK_BIOS_ROM="stock_bios.bin"
VBIOS_ROM="vbios.bin"

BOOTSPLASH="bootsplash.jpg"

################################################################################

###############################################
##   download/git clone/git pull Coreboot    ##
###############################################
downloadOrUpdateCoreboot





if [ -f "$DOCKER_SCRIPT_DIR/$BOOTSPLASH" ]; then
  cp "$DOCKER_SCRIPT_DIR/$BOOTSPLASH" "$DOCKER_COREBOOT_DIR/bootsplash.jpg"
  echo "Copied $BOOTSPLASH"
else
  echo "Missing $BOOTSPLASH"
fi

if [ -f "$DOCKER_STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
  cp "$DOCKER_STOCK_BIOS_DIR/$VBIOS_ROM"  "$DOCKER_COREBOOT_DIR/vbios.bin"
  echo "Copied $VBIOS_ROM"
else
  echo "Missing $VBIOS_ROM"
fi


##############################
##   Copy config and make   ##
##############################
configAndMake

