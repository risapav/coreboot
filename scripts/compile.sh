#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

set -xe
# set -e

# import variables
cd ~
source ./scripts/variables.sh
source ./scripts/utils.sh

e_timestamp "Entering compile.sh $@"

## Iterate through command line parameters
while :
do
  case "$1" in
    -h | --help)
      usage
      exit 0;;
    -i | --config)
        TO_CONFIGURE=true
        break;;      
    -*)
        e_error "Error: Unknown option: $1" >&2
        usage >&2
        exit 1;;
    *)
        break;;
    esac
done

##############################################################################x
## nasledovne dve casti je potrebne prerobit!!
######################
##   Copy config   ##
######################
cd $BUILD_DIR
# ak je $APP_DIR/defconfig novsi ako $BUILD_DIR/configs/defconfig
if [ "$APP_DIR/defconfig" -nt "$BUILD_DIR/configs/defconfig" ]; then
  update_config "$APP_DIR/defconfig"
fi


#update_config "$APP_DIR/defconfig"
#update_config "$BUILD_DIR/defconfig"
#update_config "$BUILD_DIR/configs/defconfig"

###
if [ "$TO_CONFIGURE" ]; then
  cd $BUILD_DIR
  if [ -f "$BUILD_DIR/.config" ]; then
      #start interactive tool
      e_note "starting configurator of .config inside $PWD $TERM"		
      make nconfig top=$BUILD_DIR
      make savedefconfig top=$BUILD_DIR
      update_config "$BUILD_DIR/defconfig"
      exit 0
  else
      e_error "configuration file $BUILD_DIR/.config must exist, try run build.sh with no switches first"
      exit 0
  fi
fi
##############################################################################x

    

################
##  Config   ##
###############
e_note "prepare defconfig"
make defconfig top=$BUILD_DIR

##############
##   make   ##
##############
e_note "crossgcc for $ARCH"

#make crossgcc-$ARCH CPUS=$(nproc)    
#util/crossgcc/buildgcc -j $(nproc)
#echo "iasl"
#make arch=$ARCH iasl CPUS=$(nproc)    
make CPUS=$(nproc)   top=$BUILD_DIR
	
exit 0
