#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
# set -xe
set -e

# import variabl
source ../scripts/variables.sh
source ../scripts/utils.sh

PATCH_DIR=$PWD/patches
cd ../$BUILD_DIR
FILES="$PATCH_DIR/*"
for f in $FILES
do
  e_warning "Processing $f file..."
  # take action on each file. $f store current file name
  git apply --stat $f
#  git apply --check $f
  git am $f
done

exit 0