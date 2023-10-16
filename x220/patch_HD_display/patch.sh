#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+

# copy Kconfig to cb_build/src/mainboard/lenovo/x220
cp Kconfig ../../cb_build/src/mainboard/lenovo/x220/
cp 

# copy gma-mainboard.ads to cb_build/src/mainboard/lenovo/x220
cp gma-mainboard.ads ../../cb_build/src/mainboard/lenovo/x220/

# copy data.vbt to cb_build/src/mainboard/lenovo/x220/variants/x220
cp data.vbt ../../cb_build/src/mainboard/lenovo/x220/variants/x220/

# credits to Katharina Fey at https://code.fe80.eu/lynxis/vbtparse
# forum https://review.coreboot.org/c/coreboot/+/28950