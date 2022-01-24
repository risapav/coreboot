#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

set -e
# set -e

# import variables
cd ~
source ./scripts/variables.sh
source ./scripts/utils.sh

trap 'err_report $LINENO' ERR

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
cd $DOCKER_BUILD_DIR
# ak je $APP_DIR/defconfig novsi ako $BUILD_DIR/configs/defconfig
if [ "$DOCKER_APP_DIR/defconfig" -nt "$DOCKER_BUILD_DIR/configs/defconfig" ]; then
  update_config "$DOCKER_APP_DIR/defconfig"
fi


#update_config "$APP_DIR/defconfig"
#update_config "$BUILD_DIR/defconfig"
#update_config "$BUILD_DIR/configs/defconfig"

###
if [ "$TO_CONFIGURE" ]; then
  cd $DOCKER_BUILD_DIR
  if [ -f "$DOCKER_BUILD_DIR/.config" ]; then
      #start interactive tool
      e_note "starting configurator of .config inside $PWD $TERM"		
      make nconfig
      make savedefconfig
      update_config "$DOCKER_BUILD_DIR/defconfig"
      exit 0
  else
      e_error "configuration file $DOCKER_BUILD_DIR/.config must exist, try run build.sh with no switches first"
      exit 0
  fi
fi
##############################################################################x

    

################
##  Config   ##
###############
e_note "prepare defconfig"
cd $DOCKER_BUILD_DIR
make defconfig

##############
##   make   ##
##############
e_note "crossgcc for $ARCH"

#make crossgcc-$ARCH CPUS=$(nproc)    
#util/crossgcc/buildgcc -j $(nproc)
cd $DOCKER_BUILD_DIR
make CPUS=$(nproc) 

#ARCH=$ARCH obj="cb_build"

e_success "--> Exiting $0, work is done"	
exit 0
