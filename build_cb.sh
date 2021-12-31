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
cd $PROJECT_ROOT_DIR 
echo "check for build DIR"
if [ ! -d "$PROJECT_COREBOOT_BUILD_DIR" ]; then
  mkdir "$PROJECT_COREBOOT_BUILD_DIR"
elif [ "$CLEAN_SLATE" ]; then
  rm -rf "$PROJECT_COREBOOT_BUILD_DIR" || true
  mkdir "$PROJECT_COREBOOT_BUILD_DIR"
fi

###
echo "check fot Docker sdk, prepare sdk"
$PROJECT_SCRIPT_DIR/build_sdk.sh 

if [[ $? -ne 0  ]]; then
	echo "build_sdk.sh exit nonzero"
	exit 1
fi

###
echo "clone coreboot framework into build DIR"
if [[ -z $(ls -A $PROJECT_COREBOOT_DIR) ]]; then
	echo "Clone framework from github"
	git clone https://github.com/coreboot/coreboot $PROJECT_COREBOOT_DIR
	cd $PROJECT_COREBOOT_DIR
	git submodule update --init --recursive 
	git clone https://github.com/coreboot/blobs.git 3rdparty/blobs/ 
	git clone https://github.com/coreboot/intel-microcode.git 3rdparty/intel-microcode/ 
else
   echo "Coreboot framework should be inside $PROJECT_COREBOOT_DIR"
fi

###
echo "compile framework parts"
docker run --rm --privileged \
	-v $PWD:$DOCKER_PROJECT_DIR \
	-v "$PWD/$PROJECT_STOCK_BIOS_DIR:$DOCKER_STOCK_BIOS_DIR:ro" \
	-v "$PWD/$PROJECT_COREBOOT_BUILD_DIR:$DOCKER_COREBOOT_BUILD_DIR" \
	-w $DOCKER_ROOT_DIR \
	$DOCKER_CONTAINER_NAME \
	$PROJECT_SCRIPT_DIR/build_api.sh
echo "part 3"
#--user "$(id -u):$(id -g)" \

###
echo "Pre build"
if [ -f "$PROJECT_STOCK_BIOS_DIR/$BOOTSPLASH" ]; then
	cp "$PROJECT_STOCK_BIOS_DIR/$BOOTSPLASH" "$PROJECT_COREBOOT_BUILD_DIR/$BOOTSPLASH"
	echo "Copied $BOOTSPLASH"
else
	echo "Missing $BOOTSPLASH"
fi

if [ -f "$PROJECT_STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
	cp "$PROJECT_STOCK_BIOS_DIR/$VBIOS_ROM"  "$PROJECT_COREBOOT_BUILD_DIR/$VBIOS_ROM"
	echo "Copied $VBIOS_ROM"
else
	echo "Missing $VBIOS_ROM"
fi

###
echo "assembly bios parts"
docker run --rm --privileged \
	--user "$(id -u):$(id -g)" \
	-v $PWD:$DOCKER_PROJECT_DIR \
	-v "$PWD/$PROJECT_STOCK_BIOS_DIR:$DOCKER_STOCK_BIOS_DIR:ro" \
	-v "$PWD/$PROJECT_COREBOOT_BUILD_DIR:$DOCKER_COREBOOT_BUILD_DIR" \
	-w $DOCKER_ROOT_DIR \
	$DOCKER_CONTAINER_NAME \
	$DOCKER_SCRIPT_DIR/compile.sh

###
echo "Post build"
## copy compilation results to out DIR, save config file
if [ ! -f "$PROJECT_COREBOOT_BUILD_DIR/coreboot.rom" ]; then
	echo "coreboot.rom as output of compile is missing..."
	exit 4;
else
	mkdir -p $PROJECT_COREBOOT_OUT_DIR
	mv "$PROJECT_COREBOOT_BUILD_DIR/coreboot.rom" "$PROJECT_COREBOOT_BUILD_DIR/coreboot.rom"
	mv "$PROJECT_COREBOOT_BUILD_DIR/.config" "$PROJECT_COREBOOT_BUILD_DIR/coreboot.config"
fi

echo "Exiting build.sh"
exit 0


# shellcheck disable=SC1091


exit

source /home/coreboot/common_scripts/./download_coreboot.sh
source /home/coreboot/common_scripts/./config_and_make.sh


################################################################################
## MODEL VARIABLES
################################################################################
MAINBOARD="lenovo"
MODEL="t410"

STOCK_BIOS_ROM="stock_bios.bin"
VBIOS_ROM="vbios.bin"

BOOTSPLASH="bootsplash.jpg"

################################################################################

###############################################
##   download/git clone/git pull Coreboot    ##
###############################################
downloadOrUpdateCoreboot








##############################
##   Copy config and make   ##
##############################
configAndMake

