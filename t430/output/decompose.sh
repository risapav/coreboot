#!/bin/bash

dd if=coreboot.rom of=coreboot-bottom.rom bs=1M count=8 
dd if=coreboot.rom of=coreboot-top.rom bs=1M skip=8