#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
set -e

echo "Entering build.sh"

# import variables
source ./scripts/variables.sh

# export COREBOOT_CONFIG=false

## Help menu
usage()
{
  echo "Usage: "
  echo
  echo "  $0 [-t <TAG>] [-c <COMMIT>] [--config] [--bleeding-edge] [--clean-slate] <model>"
  echo
  echo "  -cb, --clean-build           Purge build directory"
  echo "  -cc, --clean-config          Purge config in build directory"
  echo "  -cd, --clean-docker          Purge docker image Coreboot-sdk"
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
      -cb | --clean-build)  
        $SCRIPT_DIR/clean.sh -cb
        exit 0;;      
      -cc | --clean-config) 
        $SCRIPT_DIR/clean.sh -cc
        exit 0;;
      -cd | --clean-docker) 
        $SCRIPT_DIR/clean.sh -cd
        exit 0;;
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
				break;;
        #shift 1;;
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
echolog "checking for OUTPUT_DIR"
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir "$OUTPUT_DIR"
elif [ "$CLEAN_SLATE" ]; then
  rm -rf "$OUTPUT_DIR" || true
  mkdir "$OUTPUT_DIR"
fi

cd $ROOT_DIR 
echolog "checking for BUILD_DIR"
if [ ! -d "$BUILD_DIR" ]; then
  mkdir "$BUILD_DIR"
elif [ "$CLEAN_SLATE" ]; then
  rm -rf "$BUILD_DIR" || true
  mkdir "$BUILD_DIR"
fi

if [[ $? -ne 0  ]]; then
	echolog "BUILD_DIR not exist !"
	exit 1
else
  echolog "BUILD_DIR exist..."
fi

###
echo "--> checking for Docker SDK"
$SCRIPT_DIR/build_sdk.sh 

if [[ $? -ne 0  ]]; then
	echolog "build_sdk.sh --> Docker SDK is not prepared !"
	exit 1
fi
echolog "build_sdk.sh --> Docker SDK is prepared..."

###
echolog "checking whether Coreboot Framework is inside BUILD_DIR"
if [[ -z $(ls -A $BUILD_DIR) ]]; then
	echolog "cloning Coreboot framework from github"
	git clone https://github.com/coreboot/coreboot $BUILD_DIR
	cd $BUILD_DIR
	git submodule update --init --recursive 
	git clone https://github.com/coreboot/blobs.git 3rdparty/blobs/ 
	git clone https://github.com/coreboot/intel-microcode.git 3rdparty/intel-microcode/ 
  echolog "Coreboot Framework is cloned..."
else
   echolog "Coreboot Framework is not neccessary to clone..."
fi

###
echolog "pre build parts"
cd $ROOT_DIR
docker run --rm --privileged \
  --user "$(id -u):$(id -g)" \
	-v $PWD:$DOCKER_ROOT \
	-w $DOCKER_ROOT \
	$DOCKER_CONTAINER_NAME \
	scripts/me_extract.sh 
echolog "ME extractor is done"

###
echolog "running  pre build"
if [ -f "$STOCK_BIOS_DIR/$BOOTSPLASH" ]; then
	cp "$STOCK_BIOS_DIR/$BOOTSPLASH" "$BUILD_DIR/$BOOTSPLASH"
	echolog "Copied $BOOTSPLASH"
else
	echolog "Missing $BOOTSPLASH which shoul be inside STOCK_BIOS_DIR> $(ls -la $STOCK_BIOS_DIR)"
fi

if [ -f "$STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
	cp "$STOCK_BIOS_DIR/$VBIOS_ROM"  "$BUILD_DIR/$VBIOS_ROM"
	echolog "Copied $VBIOS_ROM"
else
	echolog "Missing $VBIOS_ROM which shoul be inside STOCK_BIOS_DIR> $(ls -la $STOCK_BIOS_DIR)"
fi

###


###
echolog "configure asemble parts $@ $0 $1"
cd $ROOT_DIR
docker run --rm --privileged \
  --user "$(id -u):$(id -g)" \
	-v $PWD:$DOCKER_ROOT \
	-w $DOCKER_ROOT \
	$DOCKER_CONTAINER_NAME \
	scripts/compile.sh $1
echolog "Compiler is done"

###
echolog "running post build"
## copy compilation results to out DIR, save config file
if [ ! -f "$BUILD_DIR/coreboot.rom" ]; then
	echolog "coreboot.rom as output of compile is missing..."
	exit 4;
else
	mkdir -p $OUTPUT_DIR
	mv "$BUILD_DIR/coreboot.rom" "$OUTPUT_DIR/coreboot.rom"
	mv "$BUILD_DIR/.config" "$OUTPUT_DIR/coreboot.config"
  echolog "coreboot.rom and .config files are copied inside OUTPUT_DIR"
fi

echolog "--> Exiting build.sh, work is done"
exit 0

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


