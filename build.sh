#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
# set -xe
set -e

# import variabl
source ./scripts/variables.sh
source ./scripts/utils.sh

e_timestamp "Entering build.sh"

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
        $HOST_SCRIPT_DIR/clean.sh -ca
        exit 0;;       
      -cb | --clean-build)  
        $HOST_SCRIPT_DIR/clean.sh -cb
        exit 0;;      
      -cc | --clean-config) 
        $HOST_SCRIPT_DIR/clean.sh -cc
        exit 0;;
      -cd | --clean-docker) 
        $HOST_SCRIPT_DIR/clean.sh -cd
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
        $HOST_SCRIPT_DIR/flash.sh 
        exit 0;;
      -g | --grubh)
        $HOST_SCRIPT_DIR/grub2.sh 
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
e_header "checking for buildtree hierarchy $HOST_ROOT_DIR"
cd $HOST_ROOT_DIR 
mkdir -p $HOST_OUTPUT_DIR $HOST_BUILD_DIR

if [[ $? -ne 0  ]]; then
  e_error "OUTPUT_DIR BUILD_DIR does not exist !"
  exit 1
else
  e_success "OUTPUT_DIR BUILD_DIR exist..."
fi
###

### check for coreboot-sdk
if [ "$TO_BUILD_SDK" ]; then
  e_header "building docker container with toolchain"
  e_warning "$COREBOOT_CROSSGCC_PARAM"
  cd $HOST_ROOT_DIR 
  git clone https://github.com/risapav/docker_coreboot util/docker/
  make -C $HOST_ROOT_DIR/util/docker coreboot-sdk COREBOOT_CROSSGCC_PARAM="$COREBOOT_CROSSGCC_PARAM"
#  make -C $HOST_ROOT_DIR/util/docker coreboot-sdk COREBOOT_CROSSGCC_PARAM="$COREBOOT_CROSSGCC_PARAM"
  exit 0
fi

###
e_header "checking for Coreboot SDK"
if [[ -z $(ls -A $HOST_BUILD_DIR) ]]; then
  e_warning "cloning Coreboot framework from github"
  cd $HOST_ROOT_DIR 
  git clone https://review.coreboot.org/coreboot $HOST_BUILD_DIR/
	cd $HOST_BUILD_DIR
	git checkout $DOCKER_COMMIT
  git clone https://github.com/coreboot/blobs.git 3rdparty/blobs/ 
  git clone https://github.com/coreboot/intel-microcode.git 3rdparty/intel-microcode/ 
  git submodule update --init --recursive 
  e_success "Coreboot Framework is cloned..."
  update_config "$HOST_APP_DIR/defconfig"
else
   e_success "Coreboot Framework is not neccessary to clone..."
fi

### COREBOOT_CROSSGCC_PARAM=
#cd $HOST_ROOT_DIR 

#if [[ $? -ne 0  ]]; then
#	e_error "build_sdk.sh --> Docker SDK is not prepared !"
#	exit 1
#else
#  e_success "build_sdk.sh --> Docker SDK is prepared..."
#fi

###
e_header "pre build parts"
 
if [ "emulation" != $MAINBOARD ]; then
  e_note "starting ME tool $HOST_ROOT_DIR"
  cd $HOST_ROOT_DIR
  make -f $HOST_SCRIPT_DIR/Makefile docker-run-local SCRIPT=$DOCKER_SCRIPT_DIR/me_extract.sh  
  e_success "ME extractor is done"

  ###
  e_note "copying files from STOCK_BIOS_DIR"
  if [ -f "$HOST_STOCK_BIOS_DIR/$BOOTSPLASH" ]; then
    cp "$HOST_STOCK_BIOS_DIR/$BOOTSPLASH" "$HOST_BUILD_DIR/$BOOTSPLASH"
    e_success "Copied $BOOTSPLASH"
  else
    e_warning "Missing $BOOTSPLASH which shoul be inside STOCK_BIOS_DIR> $(ls -la $HOST_BUILD_DIR)"
  fi

  if [ -f "$HOST_STOCK_BIOS_DIR/$VBIOS_ROM" ]; then
    cp "$HOST_STOCK_BIOS_DIR/$VBIOS_ROM"  "$HOST_BUILD_DIR/$VBIOS_ROM"
    e_success "Copied $VBIOS_ROM"
  else
    e_warning "Missing $VBIOS_ROM which shoul be inside STOCK_BIOS_DIR> $(ls -la $HOST_BUILD_DIR)"
  fi
else
    echo "Both Strings are Equal."
fi

if [ -f "$HOST_STOCK_BIOS_DIR/grub.cfg" ]; then
  cp "$HOST_STOCK_BIOS_DIR/grub.cfg"  "$HOST_BUILD_DIR/grub.cfg"
  e_success "Copied grub.cfg"
else
  e_warning "Missing grub.cfg which shoul be inside STOCK_BIOS_DIR> $(ls -la $HOST_BUILD_DIR)"
fi

###
if [ "$TO_CONFIGURE" ]; then
  e_note "starting configurator of .config inside $PWD"		
  cd $HOST_ROOT_DIR
  make -f $HOST_SCRIPT_DIR/Makefile docker-run-local SCRIPT="$DOCKER_SCRIPT_DIR/compile.sh $1" 
  exit 0
fi
e_success "pre build finished OK"

###
e_header "pokus o kompilovanie"
  cd $HOST_ROOT_DIR
  make -f $HOST_SCRIPT_DIR/Makefile docker-run-local SCRIPT="$DOCKER_SCRIPT_DIR/compile.sh"

### 
e_header "post build parts"
## copy compilation results to out DIR, save config file
if [ ! -f "$HOST_BUILD_DIR/build/coreboot.rom" ]; then
  e_error "coreboot.rom as output of compile is missing..."
  exit 1;
else
  cp -f $HOST_BUILD_DIR/build/coreboot.rom $HOST_OUTPUT_DIR/coreboot.rom
  cp -f $HOST_BUILD_DIR/.config $HOST_OUTPUT_DIR/latest.config
  cp -f $HOST_BUILD_DIR/defconfig $HOST_OUTPUT_DIR/defconfig
  e_note "coreboot.rom and .config files are copied inside OUTPUT_DIR"
fi

e_success "--> Exiting $0, work is done"
exit 0
