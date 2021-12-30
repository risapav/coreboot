#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
	
	set -e
	echo "Entering prebuild.sh"
	######################
  ##   Copy config   ##
  ######################
	cd $DOCKER_COREBOOT_DIR
pwd
  if [ -f "$DOCKER_COREBOOT_DIR/.config" ]; then
    echo "Using existing config"

    # clean config to regenerate
    make savedefconfig

    if [ -e "$DOCKER_COREBOOT_DIR/defconfig" ]; then
      mv "$DOCKER_COREBOOT_DIR/defconfig" "$DOCKER_COREBOOT_CONFIG_DIR/"
    fi
  else
    if [ -f "$DOCKER_APP_DIR/defconfig-$COREBOOT_COMMIT" ]; then
      cp "$DOCKER_APP_DIR/defconfig-$COREBOOT_COMMIT" "$DOCKER_COREBOOT_CONFIG_DIR/defconfig"
      echo "Using config-$COREBOOT_COMMIT"
    elif [ -f "$DOCKER_APP_DIR/defconfig-$COREBOOT_TAG" ]; then
      cp "$DOCKER_APP_DIR/defconfig-$COREBOOT_TAG" "$DOCKER_COREBOOT_CONFIG_DIR/defconfig"
      echo "Using config-$COREBOOT_TAG"
    else
      cp "$DOCKER_APP_DIR/coreboot.config" "$DOCKER_COREBOOT_CONFIG_DIR/defconfig"
      echo "Using default config"
    fi
  fi

  ################
  ##  Config   ##
  ###############
	cd $DOCKER_COREBOOT_DIR
  make defconfig
	make nconfig
make nconfig
make savedefconfig
  if [ "$COREBOOT_CONFIG" ]; then
    make nconfig
  fi

pwd

echo "Exiting prebuild.sh"

exit