#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

################################################################################
## VARIABLES
################################################################################
export DOCKER_CONTAINER_NAME="coreboot-sdk"

export MAINBOARD="LENOVO"
export MODEL="t410"
export STOCK_BIOS_ROM="stock_bios.bin"

# export COREBOOT_SDK_VERSION="2021-09-23_b0d87f753c"
# export COREBOOT_SDK_VERSION="6065f616eb"
export COREBOOT_SDK_VERSION="2021-04-06_7014f8258e"

export DOCKER_ROOT_DIR="/home/coreboot"
export DOCKER_SCRIPT_DIR="$DOCKER_ROOT_DIR/scripts"
export DOCKER_COMMON_SCRIPT_DIR="$DOCKER_ROOT_DIR/common_scripts"
export DOCKER_COREBOOT_DIR="$DOCKER_ROOT_DIR/coreboot"
export DOCKER_COREBOOT_CONFIG_DIR="$DOCKER_COREBOOT_DIR/configs"
export DOCKER_STOCK_BIOS_DIR="$DOCKER_ROOT_DIR/prj/$MODEL/stock_bios"




echo $MAINBOARD $DOCKER_ROOT_DIR $PWD $DOCKER_STOCK_BIOS_DIR
echo "variables.sh is done"