#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

set -e
echo "Entering variables.sh"
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

################################################################################
## MODEL VARIABLES
################################################################################
# export COREBOOT_SDK_VERSION="2021-09-23_b0d87f753c"
# export COREBOOT_SDK_VERSION="6065f616eb"
export COREBOOT_SDK_VERSION="2021-04-06_7014f8258e"

################################################################################
## docker tree
################################################################################
export DOCKER_ROOT_DIR="/home/sdk"
export DOCKER_PROJECT_DIR="$DOCKER_ROOT_DIR/prj"
export DOCKER_SCRIPT_DIR="$DOCKER_PROJECT_DIR/scripts"
export DOCKER_APP_DIR="$DOCKER_PROJECT_DIR/$MODEL"
export DOCKER_STOCK_BIOS_DIR="$DOCKER_APP_DIR/stock_bios"
#export DOCKER_COMMON_SCRIPT_DIR="$DOCKER_ROOT_DIR/common_scripts"
export DOCKER_COREBOOT_BUILD_DIR="$DOCKER_APP_DIR/build"
export DOCKER_COREBOOT_DIR="$DOCKER_COREBOOT_BUILD_DIR"
export DOCKER_OUTPUT_DIR="$DOCKER_APP_DIR/output"
export DOCKER_COREBOOT_CONFIG_DIR="$DOCKER_COREBOOT_DIR/configs"

################################################################################
## project tree
################################################################################
export PROJECT_ROOT_DIR="."
export PROJECT_SCRIPT_DIR="$PROJECT_ROOT_DIR/scripts"
export PROJECT_APP_DIR="$PROJECT_ROOT_DIR/$MODEL"
export PROJECT_STOCK_BIOS_DIR="$PROJECT_APP_DIR/stock_bios"
export PROJECT_COREBOOT_BUILD_DIR="$PROJECT_APP_DIR/build"
export PROJECT_COREBOOT_DIR="$PROJECT_COREBOOT_BUILD_DIR"
export PROJECT_OUTPUT_DIR="PROJECT_APP_DIR/output"

echo "Exiting variables.sh"
