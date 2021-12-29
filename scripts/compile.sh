#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

################################################################################
## VARIABLES
################################################################################
source ./prj/scripts/variables.sh

# split code
$DOCKER_SCRIPT_DIR/me_extract.sh

# neutralize me

# pre build coreboot
$DOCKER_SCRIPT_DIR/prebuild.sh

# build coreboot
	cd $DOCKER_COREBOOT_DIR
pwd
echo "Build coreboot..."
make 











echo $MAINBOARD $DOCKER_ROOT_DIR $PWD
echo "Compile is done"

exit

#!/bin/bash

printf "Starting auto run"

bash ./cb-helper download_code || exit 1
bash ./cb-helper build_utils || exit 1
bash ./cb-helper split_bios || exit 1
bash ./cb-helper neuter_me || exit 1
bash ./cb-helper pre_build_coreboot || exit 1
bash ./cb-helper build_coreboot || exit 1
bash ./cb-helper build_grub || exit 1
bash ./cb-helper assemble_grub || exit 1
bash ./cb-helper config_seabios || exit 1
bash ./cb-helper install_grub || exit 1

printf "Auto run finished successfully"