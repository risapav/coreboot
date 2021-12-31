#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
set -e

echo "Entering build.sh"

# import variables
source ./scripts/variables.sh


## Help menu
usage()
{
  echo "Usage: "
  echo
  echo "  $0 [-t <TAG>] [-c <COMMIT>] [--config] [--bleeding-edge] [--clean-slate] <model>"
  echo
  echo "  --bleeding-edge              Build from the latest commit"
  echo "  --clean-slate                Purge previous build directory and config"
  echo "  -c, --commit <commit>        Git commit hash"
  echo "  --flash                      Flash BIOS if build is successful"
  echo "  -h, --help                   Show this help"
  echo "  -i, --config                 Execute with interactive make config"
  echo "  -t, --tag <tag>              Git tag/version"
  echo
  echo "If a tag, commit or bleeding-edge flag is not given, the latest Coreboot release will be built."
  echo
  echo
  echo "Available models:"
  for AVAILABLE_MODEL in $AVAILABLE_MODELS; do
      echo "$(printf '\t')$AVAILABLE_MODEL"
  done
}

## Iterate through command line parameters
while :
do
    case "$1" in
      --bleeding-edge)
        COREBOOT_COMMIT="master"
        shift 1;;
      --clean-slate)
        CLEAN_SLATE=true
        shift 1;;
      -c | --commit)
        COREBOOT_COMMIT="$2"
        shift 2;;
      --flash)
        FLASH_AFTER_BUILD=true
        shift 1;;
      -h | --help)
        usage
        exit 0;;
      -i | --config)
        COREBOOT_CONFIG=true
        shift 1;;
      -t | --tag)
        COREBOOT_TAG="$2"
        shift 2;;
      -*)
        echo "Error: Unknown option: $1" >&2
        usage >&2
        exit 1;;
      *)
        break;;
    esac
done

###
cd $ROOT_DIR 
echo "--> checking for BUILD_DIR"
if [ ! -d "$BUILD_DIR" ]; then
  mkdir "$BUILD_DIR"
elif [ "$CLEAN_SLATE" ]; then
  rm -rf "$BUILD_DIR" || true
  mkdir "$BUILD_DIR"
fi

if [[ $? -ne 0  ]]; then
	echo "--> BUILD_DIR not exist !"
	exit 1
else
  echo "--> BUILD_DIR exist..."
fi

###
echo "--> checking for Docker SDK"
$SCRIPT_DIR/build_sdk.sh 

if [[ $? -ne 0  ]]; then
	echo "--> build_sdk.sh --> Docker SDK is not prepared !"
	exit 1
fi
echo "--> build_sdk.sh --> Docker SDK is prepared..."

###
echo "--> checking whether Coreboot Framework is inside BUILD_DIR"
if [[ -z $(ls -A $BUILD_DIR) ]]; then
	echo "--> cloning framework from github"
	git clone https://github.com/coreboot/coreboot $BUILD_DIR
	cd $BUILD_DIR
	git submodule update --init --recursive 
	git clone https://github.com/coreboot/blobs.git 3rdparty/blobs/ 
	git clone https://github.com/coreboot/intel-microcode.git 3rdparty/intel-microcode/ 
  echo "--> Coreboot Framework is cloned..."
else
   echo "--> Coreboot Framework is not neccessary to clone..."
fi
echo "--> Coreboot Framework should be inside BUILD_DIR> $BUILD_DIR"

###
echo "--> compiling framework parts"
cd $ROOT_DIR
docker run --rm --privileged \
  --user "$(id -u):$(id -g)" \
	-v $PWD:$DOCKER_ROOT \
	-w $DOCKER_ROOT \
	$DOCKER_CONTAINER_NAME \
	scripts/me_extract.sh 
echo "--> ME extractor is done"

###
echo "--> running  pre build"
if [ -f "$STOCK_BIOS_DIR/$BOOTSPLASH" ]; then
	cp "$STOCK_BIOS_DIR/$BOOTSPLASH" "$BUILD_DIR/$BOOTSPLASH"
	echo "--> Copied $BOOTSPLASH"
else
	echo "--> Missing $BOOTSPLASH inside STOCK_BIOS_DIR> $(ls -la $STOCK_BIOS_DIR)"
fi

if [ -f "$STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
	cp "$STOCK_BIOS_DIR/$VBIOS_ROM"  "$BUILD_DIR/$VBIOS_ROM"
	echo "--> Copied $VBIOS_ROM"
else
	echo "--> Missing $VBIOS_ROM $(ls -la $STOCK_BIOS_DIR)"
fi

###
cd $ROOT_DIR 
echo "--> checking for OUTPUT_DIR"
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir "$OUTPUT_DIR"
elif [ "$CLEAN_SLATE" ]; then
  rm -rf "$OUTPUT_DIR" || true
  mkdir "$OUTPUT_DIR"
fi

###
echo "--> configure asemble parts"
cd $ROOT_DIR
docker run --rm --privileged \
  --user "$(id -u):$(id -g)" \
	-v $PWD:$DOCKER_ROOT \
	-w $DOCKER_ROOT \
	$DOCKER_CONTAINER_NAME \
	scripts/compile.sh 
echo "--> Compiler is done"

###


exit

###
echo "--> Configure config"



exit
###
echo "--> assembling bios parts"
docker run --rm --privileged \
	--user "$(id -u):$(id -g)" \
	-v $PWD:$DOCKER_ROOT \
	-w $DOCKER_ROOT \
	$DOCKER_CONTAINER_NAME \	
	scripts/compile.sh

###
echo "--> running post build"
## copy compilation results to out DIR, save config file
if [ ! -f "$BUILD_DIR/coreboot.rom" ]; then
	echo "--> coreboot.rom as output of compile is missing..."
	exit 4;
else
	mkdir -p $OUTPUT_DIR
	mv "$BUILD_DIR/coreboot.rom" "$OUTPUT_DIR/coreboot.rom"
	mv "$BUILD_DIR/.config" "$OUTPUT_DIR/coreboot.config"
fi

echo "--> Exiting build.sh, work is done"
exit 0


# shellcheck disable=SC1091


exit

source /home/coreboot/common_scripts/./download_coreboot.sh
source /home/coreboot/common_scripts/./config_and_make.sh

################################################################################

###############################################
##   download/git clone/git pull Coreboot    ##
###############################################
downloadOrUpdateCoreboot








##############################
##   Copy config and make   ##
##############################
configAndMake




  cd "$DOCKER_COREBOOT_DIR" || exit;



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
  make


