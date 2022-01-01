#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

set -e

# import variables
source ./scripts/variables.sh

echolog "Entering compile.sh $@ $0 $1"

## Iterate through command line parameters
while :
do
    case "$1" in
      --flash)
        FLASH_AFTER_BUILD=true
        shift 1;;
      -h | --help)
        usage
        exit 0;;
      -i | --config)
        COREBOOT_CONFIG=true
        shift 1;;
      -*)
        echolog "Error: Unknown option: $1" >&2
        usage >&2
        exit 1;;
      *)
        break;;
    esac
done


######################
##   Copy config   ##
######################
cd $BUILD_DIR

if [ -f "$BUILD_DIR/.config" ]; then

	#start interactive tool
  if [ "$COREBOOT_CONFIG" ]; then
		#cd $APP_DIR
export TERM=xterm	
		echolog "starting configuration edition of .config inside $PWD"
    make nconfig
		exit 0
  fi
	
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