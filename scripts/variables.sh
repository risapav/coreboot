#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
set -e

function err_report() {
    echo "!!! -----> Error on line $1 <----- !!!"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
}

trap 'err_report $LINENO' ERR

#echo "Entering variables.sh $PWD"
################################################################################
## VARIABLES - necessary update before 
################################################################################
export DOCKER_CONTAINER_NAME="coreboot/coreboot-sdk"

export COREBOOT_IMAGE_TAG="2021-12-29_ce134ababd"
export DOCKER_COMMIT="e565f75221"
export COREBOOT_CROSSGCC_PARAM="build-arm build-riscv build-i386 build-x64 build_gcc build_iasl build_nasm"

## log file
export LOG_FILE="log.txt"
################################################################################
## MODEL VARIABLES
################################################################################

export ARCH="i386" 
## maiboard vendor
#export MAINBOARD="lenovo"
export MAINBOARD="emulation"

## mainboard model
#export MODEL="t410"
#export MODEL="t430"
export MODEL="qemu-i440fx"

## original bios to extract ME from
export STOCK_BIOS_ROM="stock_bios.bin"
export VBIOS_ROM="vgabios.bin"

## picture 
export BOOTSPLASH="bootsplash.jpg"

#export COREBOOT_SDK_REPOSITORY="http://github.com/risapav/docker_coreboot.git"

################################################################################
## project tree
################################################################################
## $PRJ                   - root       dir
## $PRJ/sdk               - coreboot   dir in docker container
## $PRJ/script            - script     dir
## $PRJ/$MODEL            - app        dir 
## $PRJ/$MODEL/build      - build      dir 
## $PRJ/$MODEL/output     - output     dir
## $PRJ/$MODEL/stock_bios - stock_bios dir
################################################################################
export APP_DIR="$MODEL"
export BUILD_DIR="cb_build"
export CCACHE_DIR=".ccache"
export SCRIPT_DIR="scripts"
export OUTPUT_DIR="$APP_DIR/output"
export STOCK_BIOS_DIR="$APP_DIR/stock_bios"


export HOST_ROOT_DIR="$PWD"
export HOST_APP_DIR="$HOST_ROOT_DIR/$APP_DIR"
export HOST_BUILD_DIR="$HOST_ROOT_DIR/$BUILD_DIR"
export HOST_CCACHE_DIR="$HOST_ROOT_DIR/$CCACHE_DIR"
export HOST_SCRIPT_DIR="$HOST_ROOT_DIR/$SCRIPT_DIR"
export HOST_STOCK_BIOS_DIR="$HOST_ROOT_DIR/$STOCK_BIOS_DIR"
export HOST_OUTPUT_DIR="$HOST_ROOT_DIR/$OUTPUT_DIR"

export DOCKER_ROOT_DIR="/home/coreboot"
export DOCKER_APP_DIR="$DOCKER_ROOT_DIR/$APP_DIR"
export DOCKER_BUILD_DIR="$DOCKER_ROOT_DIR/$BUILD_DIR"
export DOCKER_CCACHE_DIR="$DOCKER_ROOT_DIR/$CCACHE_DIR"
export DOCKER_SCRIPT_DIR="$DOCKER_ROOT_DIR/$SCRIPT_DIR"
export DOCKER_STOCK_BIOS_DIR="$DOCKER_ROOT_DIR/$STOCK_BIOS_DIR"
export DOCKER_OUTPUT_DIR="$DOCKER_ROOT_DIR/$OUTPUT_DIR"

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
	if [ "${1}" -nt "$HOST_BUILD_DIR/configs/defconfig" ]; then
		cp -fv "${1}" "$HOST_BUILD_DIR/configs/defconfig"
	fi
	rm -fv "$HOST_BUILD_DIR/.config"
)

function print_supported() {
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

#qemu.exe -L . -m 128 -bios coreboot.rom -hda linux.img -soundhw all -localtime -M pc
