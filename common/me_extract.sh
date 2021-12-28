#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+


#######################
##   build ifdtool   ##
#######################
if [ ! -f "$DOCKER_COREBOOT_DIR/util/ifdtool/ifdtool" ]; then
  # Make ifdtool
  cd "$DOCKER_COREBOOT_DIR/util/ifdtool" || exit
  make
  chmod +x ifdtool || exit
fi

###################################################################################
##  Extract Intel ME firmware, Gigabit Ethernet firmware, flash descriptor, etc  ##
###################################################################################
if [ ! -d "$DOCKER_COREBOOT_DIR/3rdparty/blobs/mainboard/$MAINBOARD/$MODEL/" ]; then
  mkdir -p "$DOCKER_COREBOOT_DIR/3rdparty/blobs/mainboard/$MAINBOARD/$MODEL/"
fi


if [ ! -f "$DOCKER_COREBOOT_DIR/3rdparty/blobs/mainboard/$MAINBOARD/$MODEL/gbe.bin" ]; then
  cd "$DOCKER_COREBOOT_DIR/3rdparty/blobs/mainboard/$MAINBOARD/$MODEL/" || exit

  cp "$DOCKER_COREBOOT_DIR/util/ifdtool/ifdtool" .

  # ALWAYS COPY THE ORIGINAL.  Never modified the original stock bios file
  cp "$DOCKER_STOCK_BIOS_DIR/$STOCK_BIOS_ROM" .

  # unlock, extract blobs and rename
  ./ifdtool -u "$STOCK_BIOS_ROM" || exit
  ./ifdtool -x "$STOCK_BIOS_ROM" || exit
  mv flashregion_0_flashdescriptor.bin descriptor.bin
  mv flashregion_2_intel_me.bin me.bin
  mv flashregion_3_gbe.bin gbe.bin
  
  ls -la .
  pwd

  # clean up
  rm ifdtool
  rm flashregion_1_bios.bin
fi

echo $MAINBOARD $DOCKER_ROOT_DIR $PWD
echo "ME extractor is done"

exit