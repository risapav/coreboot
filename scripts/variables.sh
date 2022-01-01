#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
set -e

#echo "Entering variables.sh $PWD"
################################################################################
## VARIABLES - necessary update before 
################################################################################
export DOCKER_CONTAINER_NAME="coreboot-sdk"

## maiboard vendor
export MAINBOARD="lenovo"

## mainboard model
export MODEL="t410"

## original bios to extract ME from
export STOCK_BIOS_ROM="stock_bios.bin"
export VBIOS_ROM="vbios.bin"

## picture 
export BOOTSPLASH="bootsplash.jpg"



## log file
export LOG_FILE="log.txt"
################################################################################
## MODEL VARIABLES
################################################################################
# export COREBOOT_SDK_VERSION="2021-09-23_b0d87f753c"
# export COREBOOT_SDK_VERSION="6065f616eb"
export COREBOOT_SDK_VERSION="2021-04-06_7014f8258e"

export COREBOOT_SDK_REPOSITORY="http://github.com/risapav/docker_coreboot.git"

################################################################################
## project tree
################################################################################
# $PRJ                   - root       dir
# $PRJ/sdk               - coreboot   dir in docker container
# $PRJ/script            - script     dir
# $PRJ/$MODEL            - app        dir 
# $PRJ/$MODEL/build      - build      dir 
# $PRJ/$MODEL/output     - output     dir
# $PRJ/$MODEL/stock_bios - stock_bios dir
################################################################################
export HOST_ROOT="."
export DOCKER_ROOT="/home/sdk"
export ROOT_DIR=$PWD
export WORKER_DIR="$ROOT_DIR/worker"
export SCRIPT_DIR="$ROOT_DIR/scripts"
export APP_DIR="$ROOT_DIR/$MODEL"
export BUILD_DIR="$ROOT_DIR/$MODEL/build"
export OUTPUT_DIR="$ROOT_DIR/$MODEL/output"
export STOCK_BIOS_DIR="$ROOT_DIR/$MODEL/stock_bios"

################################################################################
## https://wiki.bash-hackers.org/
## https://devhints.io/bash
################################################################################
# printenv

echolog()
{
	printf "%(%Y-%m-%d %T)T ----> %s\n" -1 "$@"
	printf "%(%Y-%m-%d %T)T ----> %s\n" -1 "$@" >> $OUTPUT_DIR/$LOG_FILE
}
