#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

set -e

# import variables
source ./scripts/variables.sh

echo "--> Entering compile.sh"
######################
##   Copy config   ##
######################
cd $BUILD_DIR

if [ -f "$BUILD_DIR/.config" ]; then
	echo "--> Using existing config $BUILD_DIR/.config"

	# clean config to regenerate
	make savedefconfig

	if [ -e "$BUILD_DIR/defconfig" ]; then
		mv -i "$BUILD_DIR/defconfig" "$OUTPUT_DIR/defconfig.old"
	fi
else
	if [ -f "$APP_DIR/defconfig" ]; then
		cp "$APP_DIR/defconfig" "$BUILD_DIR/configs/defconfig"
		echo "--> Using config $APP_DIR/defconfig"
	elif [ -f "$OUTPUT_DIR/defconfig.old" ]; then
		cp "$OUTPUT_DIR/defconfig.old" "$BUILD_DIR/configs/defconfig"
		echo "--> Using config $OUTPUT_DIR/defconfig.old"
	else
		make menuconfig
		echo "--> Using config --> make menuconfig"
	fi
fi


  ################
  ##  Config   ##
  ###############
  make defconfig

  if [ "$COREBOOT_CONFIG" ]; then
    make nconfig
  fi

  ##############
  ##   make   ##
  ##############
	echo "crossgcc for i386"
	make crossgcc-i386 CPUS=$(nproc)    
	util/crossgcc/buildgcc -j $(nproc)
	echo "iasl"
	make iasl CPUS=$(nproc)    
  make CPUS=$(nproc)    
	
exit