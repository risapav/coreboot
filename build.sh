#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
set -e

echo "Entering build.sh"

# import variabl
source ./scripts/variables.sh
source ./scripts/utils.sh

## Help menu
usage()
{
  echo "Usage: "
  echo
  echo "  $0 [-t <TAG>] [-c <COMMIT>] [--config] [--bleeding-edge] [--clean-slate] <model>"
  echo
  echo "  -bd, --build-sdk             Install docker image Coreboot-sdk"
  echo "  -ca, --clean-all             Purge ALL--> -cb -cc -cd together, total wipe out"
  echo "  -cb, --clean-build           Purge build directory"
  echo "  -cc, --clean-config          Purge config in build directory"
  echo "  -cd, --clean-docker          Purge docker image Coreboot-sdk"
  echo "  --bleeding-edge              Build from the latest commit"
  echo "  --clean-slate                Purge previous build directory and config"
  echo "  -c, --commit <commit>        Git commit hash"
  echo "  -f, --flash                  Flash BIOS if build is successful"
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
      -bd | --build-sdk)  
        TO_BUILD_SDK=true
        break;;      
      -ca | --clean-all)  
        $SCRIPT_DIR/clean.sh -ca
        exit 0;;       
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
      -f | --flash)
        $SCRIPT_DIR/flash.sh 
        exit 0;;
      -h | --help)
        usage
        print_supported
        exit 0;;
      -i | --config)
        TO_CONFIGURE=true
        break;;
      -t | --tag)
        COREBOOT_TAG="$2"
        shift 2;;
      -*)
        e_error "Error: Unknown option: $1" >&2
        usage >&2
        exit 1;;
      -s|--supported)		shift; PRINTSUPPORTED="$1"; shift;;
      *)
        break;;
    esac
done

###
if [ -n "$PRINTSUPPORTED" ]; then
  print_supported
  exit 0
fi

###
e_header "checking for buildtree hierarchy"
cd $ROOT_DIR 
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir "$OUTPUT_DIR"
fi

if [[ $? -ne 0  ]]; then
  e_error "OUTPUT_DIR not exist !"
  exit 1
else
  e_success "OUTPUT_DIR exist..."
fi

if [ ! -d "$BUILD_DIR" ]; then
  mkdir "$BUILD_DIR"
fi

if [[ $? -ne 0  ]]; then
  e_error "BUILD_DIR not exist !"
  exit 1
else
  e_success "BUILD_DIR exist..."
fi
###

### check for coreboot-sdk
if [ "$TO_BUILD_SDK" ]; then
  e_header "building docker container with toolchain"
#  make docker-build-coreboot BUILD_CMD="/bin/bash -l"
#        $SCRIPT_DIR/build_sdk.sh
  cd util/docker
  make coreboot-sdk COREBOOT_CROSSGCC_PARAM="build-x64 build_gcc build_iasl build_nasm"
  exit 0
fi

###
e_header "checking for Coreboot SDK"
if [[ -z $(ls -A $BUILD_DIR) ]]; then
  e_warning "cloning Coreboot framework from github"
  git clone --branch $COREBOOT_SDK_TAG https://github.com/coreboot/coreboot $BUILD_DIR/
  cd $BUILD_DIR
  git clone https://github.com/coreboot/blobs.git 3rdparty/blobs/ 
  git clone https://github.com/coreboot/intel-microcode.git 3rdparty/intel-microcode/ 
  git submodule update --init --recursive 
  e_success "Coreboot Framework is cloned..."
else
   e_success "Coreboot Framework is not neccessary to clone..."
fi

### COREBOOT_CROSSGCC_PARAM=


#if [[ $? -ne 0  ]]; then
#	e_error "build_sdk.sh --> Docker SDK is not prepared !"
#	exit 1
#else
#  e_success "build_sdk.sh --> Docker SDK is prepared..."
#fi

###
e_header "pre build parts"
e_note "starting ME tool"
make docker-run-local SCRIPT=$DOCKER_ROOT/scripts/me_extract.sh  
e_success "ME extractor is done"

###
e_note "copying files from STOCK_BIOS_DIR"
if [ -f "$STOCK_BIOS_DIR/$BOOTSPLASH" ]; then
  cp "$STOCK_BIOS_DIR/$BOOTSPLASH" "$BUILD_DIR/$BOOTSPLASH"
  e_success "Copied $BOOTSPLASH"
else
  e_warning "Missing $BOOTSPLASH which shoul be inside STOCK_BIOS_DIR> $(ls -la $STOCK_BIOS_DIR)"
fi

if [ -f "$STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
  cp "$STOCK_BIOS_DIR/$VBIOS_ROM"  "$BUILD_DIR/$VBIOS_ROM"
  e_success "Copied $VBIOS_ROM"
else
  e_warning "Missing $VBIOS_ROM which shoul be inside STOCK_BIOS_DIR> $(ls -la $STOCK_BIOS_DIR)"
fi

###
if [ "$TO_CONFIGURE" ]; then
  e_note "starting configurator of .config inside $PWD"		
  make docker-run-local SCRIPT="$DOCKER_ROOT/scripts/compile.sh $1" 
  exit 0
fi

###
e_header "pokus o kompilovanie"
make docker-run-local SCRIPT=$DOCKER_ROOT/scripts/compile.sh 

### 
e_header "post build parts"
## copy compilation results to out DIR, save config file
if [ ! -f "$BUILD_DIR/build/coreboot.rom" ]; then
  e_error "coreboot.rom as output of compile is missing..."
  exit 1;
else
  cp -f "$BUILD_DIR/build/coreboot.rom" "$OUTPUT_DIR/coreboot.rom"
  cp -f "$BUILD_DIR/.config" "$OUTPUT_DIR/latest.config"
  cp -f "$BUILD_DIR/defconfig" "$OUTPUT_DIR/defconfig"
  e_note "coreboot.rom and .config files are copied inside OUTPUT_DIR"
fi

e_success "--> Exiting build.sh, work is done"
exit 0
