#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

################################################################################
## VARIABLES
################################################################################
export DOCKER_CONTAINER_NAME="coreboot-sdk"

export MAINBOARD="lenovo"
export MODEL="t410"
export STOCK_BIOS_ROM="stock_bios.bin"

# export COREBOOT_SDK_VERSION="2021-09-23_b0d87f753c"
# export COREBOOT_SDK_VERSION="6065f616eb"
export COREBOOT_SDK_VERSION="2021-04-06_7014f8258e"

# docker tree
export DOCKER_ROOT_DIR="/home/sdk"
export DOCKER_PROJECT_DIR="$DOCKER_ROOT_DIR/prj"
export DOCKER_SCRIPT_DIR="$DOCKER_PROJECT_DIR/scripts"
export DOCKER_APP_DIR="$DOCKER_PROJECT_DIR/$MODEL"
export DOCKER_STOCK_BIOS_DIR="$DOCKER_APP_DIR/stock_bios"
#export DOCKER_COMMON_SCRIPT_DIR="$DOCKER_ROOT_DIR/common_scripts"
export DOCKER_COREBOOT_DIR="$DOCKER_ROOT_DIR/coreboot"
export DOCKER_COREBOOT_BUILD_DIR="$DOCKER_COREBOOT_DIR/build"
export DOCKER_COREBOOT_CONFIG_DIR="$DOCKER_COREBOOT_DIR/configs"

# project tree
export PROJECT_ROOT_DIR="."
export PROJECT_SCRIPT_DIR="$PROJECT_ROOT_DIR/scripts"
export PROJECT_APP_DIR="$PROJECT_ROOT_DIR/$MODEL"
export PROJECT_STOCK_BIOS_DIR="$PROJECT_APP_DIR/stock_bios"
export PROJECT_COREBOOT_BUILD_DIR="$PROJECT_APP_DIR/build"

echo $MAINBOARD $DOCKER_ROOT_DIR $PWD $DOCKER_STOCK_BIOS_DIR
echo "variables.sh is done"