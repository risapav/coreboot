#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
set -e

#echo "Entering variables.sh $PWD"
################################################################################
## VARIABLES - necessary update before 
################################################################################
export DOCKER_CONTAINER_NAME="coreboot/coreboot-sdk"

export COREBOOT_IMAGE_TAG="2021-12-29_ce134ababd"
export DOCKER_COMMIT="e565f75221"
export COREBOOT_CROSSGCC_PARAM="build-arm build-i386 build-x64 build_gcc build_iasl build_nasm"

## log file
export LOG_FILE="log.txt"
################################################################################
## MODEL VARIABLES
################################################################################
## maiboard vendor
export MAINBOARD="lenovo"

## mainboard model
export MODEL="t410"

## original bios to extract ME from
export STOCK_BIOS_ROM="stock_bios.bin"
export VBIOS_ROM="vbios.bin"

## picture 
export BOOTSPLASH="bootsplash.jpg"

#export COREBOOT_SDK_REPOSITORY="http://github.com/risapav/docker_coreboot.git"

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
export DOCKER_ROOT="/home/coreboot"
export ROOT_DIR=$PWD
#export ROOT_DIR=$DOCKER_ROOT
export WORKER_DIR="$ROOT_DIR/worker"
export SCRIPT_DIR="$ROOT_DIR/scripts"
export APP_DIR="$ROOT_DIR/$MODEL"
#export BUILD_DIR="$ROOT_DIR/.ccache"
export BUILD_DIR="$ROOT_DIR/$MODEL/build"
export OUTPUT_DIR="$ROOT_DIR/$MODEL/output"
export STOCK_BIOS_DIR="$ROOT_DIR/$MODEL/stock_bios"

################################################################################
## toopchain variables
################################################################################
export TOOLCHAIN="/opt/xgcc"
export XGCCPATH="/opt/xgcc/bin"

################################################################################
## flashing rom variables
################################################################################
export FLASH_PROGRAMMER="ch341a_spi"
export FLASH_MEMORY="MX25L6405D" 

################################################################################
## https://wiki.bash-hackers.org/
## https://devhints.io/bash
################################################################################
# printenv


function update_config()
(
	if [ "${1}"  -nt "$BUILD_DIR/defconfig" ]; then
		cp -fv "${1}" "$BUILD_DIR/defconfig"
	fi
	if [ "${1}" -nt "$BUILD_DIR/configs/defconfig" ]; then
		cp -fv "${1}" "$BUILD_DIR/configs/defconfig"
	fi
	rm -fv "$BUILD_DIR/.config"
)

print_supported() {
	case "$PRINTSUPPORTED" in
		AUTOCONF|autoconf)  printf "%s\n" "$GCC_AUTOCONF_VERSION";;
		BINUTILS|binutils)  printf "%s\n" "$BINUTILS_VERSION";;
		CLANG|clang)  printf "%s\n" "$CLANG_VERSION";;
		GCC|gcc)  printf "%s\n" "$GCC_VERSION";;
		GMP|gmp)   printf "%s\n" "$GMP_VERSION";;
		IASL|iasl) printf "%s\n" "$IASL_VERSION";;
		MPC|mpc)  printf "%s\n" "$MPC_VERSION";;
		MPFR|mpfr)  printf "%s\n" "$MPFR_VERSION";;
		NASM|nasm) printf "%s\n" "${NASM_VERSION}";;
		*) printf "Unknown tool %s\n" "$PRINTSUPPORTED";;
	esac
}

