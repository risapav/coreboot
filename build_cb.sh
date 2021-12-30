#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
set -e

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

# part no.1
# check for build DIR
if [ ! -d "$PROJECT_COREBOOT_BUILD_DIR" ]; then
  mkdir "$PROJECT_COREBOOT_BUILD_DIR"
elif [ "$CLEAN_SLATE" ]; then
  rm -rf "$PROJECT_COREBOOT_BUILD_DIR" || true
  mkdir "$PROJECT_COREBOOT_BUILD_DIR"
fi

# part no.2
# check fot Docker sdk, prepare sdk
$PROJECT_SCRIPT_DIR/build_sdk.sh 

if [[ $? -ne 0  ]]; then
	echo "build_sdk.sh exit nonzero"
	exit 1
fi
echo "build_sdk.sh exit zero"
exit 1
# part no.3
# entering into docker powered sdk, input is compile script


## Run Docker build_sdk
docker run --rm --privileged \
	--user "$(id -u):$(id -g)" \
	-p 4500:4500 \
	-v /dev/bus/usb:/dev/bus/usb \
	-v $PWD:$DOCKER_PROJECT_DIR \
	-v "$PWD/$PROJECT_STOCK_BIOS_DIR:$DOCKER_STOCK_BIOS_DIR:ro" \
	-v "$PWD/$PROJECT_COREBOOT_BUILD_DIR:$DOCKER_COREBOOT_BUILD_DIR" \
	-w $DOCKER_ROOT_DIR \
	$DOCKER_CONTAINER_NAME \
	$DOCKER_SCRIPT_DIR/compile.sh




# part no.4
#####################
##   Post build    ##
#####################
## copy compilation results to out DIR, save config file
if [ ! -f "$DOCKER_COREBOOT_DIR/build/coreboot.rom" ]; then
	echo "coreboot.rom as output of compile is missing..."
	exit 4;
else
	mkdir -p $DOCKER_ROOT_DIR/prj/out
	mv "$DOCKER_COREBOOT_DIR/build/coreboot.rom" "$DOCKER_ROOT_DIR/prj/out/coreboot.rom"
	mv "$DOCKER_COREBOOT_DIR/build/.config" "$DOCKER_ROOT_DIR/prj/out/coreboot.config"
fi

echo "build.sh is done"
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





if [ -f "$DOCKER_SCRIPT_DIR/$BOOTSPLASH" ]; then
  cp "$DOCKER_SCRIPT_DIR/$BOOTSPLASH" "$DOCKER_COREBOOT_DIR/bootsplash.jpg"
  echo "Copied $BOOTSPLASH"
else
  echo "Missing $BOOTSPLASH"
fi

if [ -f "$DOCKER_STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
  cp "$DOCKER_STOCK_BIOS_DIR/$VBIOS_ROM"  "$DOCKER_COREBOOT_DIR/vbios.bin"
  echo "Copied $VBIOS_ROM"
else
  echo "Missing $VBIOS_ROM"
fi


##############################
##   Copy config and make   ##
##############################
configAndMake

