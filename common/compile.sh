#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

################################################################################
## VARIABLES
################################################################################
source ./prj/common/variables.sh

###################################################################################
##  Extract Intel ME firmware, Gigabit Ethernet firmware, flash descriptor, etc  ##
###################################################################################
./prj/common/me_extract.sh

echo $MAINBOARD $DOCKER_ROOT_DIR $PWD
echo "Compile is done"

exit