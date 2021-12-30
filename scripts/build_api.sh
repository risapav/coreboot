#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
# to show where in script the error is

set -e
################################################################################
## VARIABLES
################################################################################
echo "Entering build_api.sh"
source ./prj/scripts/variables.sh

# split code
$DOCKER_SCRIPT_DIR/me_extract.sh

cd $DOCKER_COREBOOT_BUILD_DIR && make crossgcc-i386 CPUS=$(nproc)
cd $DOCKER_COREBOOT_BUILD_DIR/util/cbfstool && make CPUS=$(nproc)
cd ${DOCKER_COREBOOT_BUILD_DIR}/ifdtool && make CPUS=$(nproc)
cd $DOCKER_COREBOOT_BUILD_DIR/util/cbmem && make CPUS=$(nproc)

echo "Exiting build_api.sh"
exit 0