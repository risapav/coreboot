#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
# to show where in script the error is

set -e
################################################################################
## VARIABLES
################################################################################
echo "Entering build_api.sh"

# import variables
source ./scripts/variables.sh

# split code
$SCRIPT_DIR/me_extract.sh

cd $BUILD_DIR && make crossgcc-i386 CPUS=$(nproc)
cd $BUILD_DIR/util/cbfstool && make CPUS=$(nproc)
cd $BUILD_DIR}/ifdtool && make CPUS=$(nproc)
cd $BUILD_DIR/util/cbmem && make CPUS=$(nproc)

echo "Exiting build_api.sh"
exit 0