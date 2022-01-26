#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# to show where in script the error is
# set -xe
set -e

# import variabl
source ./scripts/variables.sh
source ./scripts/utils.sh

GRUB_PAYLOAD_DIR="$HOST_OUTPUT_DIR/payload/grub"
GRUB_RESOURCE_DIR="$HOST_ROOT_DIR/grub"

source "$GRUB_RESOURCE_DIR/modules.list"

e_header "checking for grub buildtree hierarchy $GRUB_PAYLOAD_DIR"
cd $HOST_ROOT_DIR 
mkdir -p $GRUB_PAYLOAD_DIR

# Separate GRUB payload per keymap. This saves space in the ROM, otherwise
# a lot of space would be used if every keymap was stored in a single image

for keylayoutfile in $GRUB_RESOURCE_DIR/keymap/*.gkb; do
	if [ ! -f "${keylayoutfile}" ]; then
		continue
	fi
	keymap="${keylayoutfile##$GRUB_RESOURCE_DIR/keymap/}"
	keymap="${keymap%.gkb}"

	grub-mkstandalone \
		--grub-mkimage="grub-mkimage" \
		-O i386-coreboot \
		-o $GRUB_PAYLOAD_DIR/grub_${keymap}.elf \
		-d $GRUB_RESOURCE_DIR/grub-core/ \
		--fonts= --themes= --locales=  \
		--modules="${grub_modules}" \
		--install-modules="${grub_install_modules}" \
		/boot/grub/grub.cfg=$GRUB_RESOURCE_DIR/config/grub_memdisk.cfg \
		/boot/grub/layouts/${keymap}.gkb=${keylayoutfile}


	if [ "${keymap}" = "usqwerty" ]; then	
		cp $GRUB_RESOURCE_DIR/config/grub.cfg $GRUB_PAYLOAD_DIR/grub_usqwerty.cfg
	else
		sed "s/usqwerty/${keymap}/" < $GRUB_RESOURCE_DIR/config/grub.cfg > $GRUB_PAYLOAD_DIR/grub_${keymap}.cfg
	fi

	sed "s/grubtest.cfg/grub.cfg/" < $GRUB_PAYLOAD_DIR/grub_${keymap}.cfg > $GRUB_PAYLOAD_DIR/grub_${keymap}_test.cfg

	printf "Generated: '$GRUB_PAYLOAD_DIR/grub_%s.elf' and configs.'\n" "${keymap}"
done

printf "Done! Check $GRUB_PAYLOAD_DIR/ to see the files.\n\n"

exit 0
