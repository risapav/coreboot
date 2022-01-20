#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# import variables
source ./scripts/variables.sh

echolog "entering to $0 $1"

flashrom -p $FLASH_PROGRAMMER -w $OUTPUT_DIR/coreboot.rom -c $FLASH_MEMORY

exit 0