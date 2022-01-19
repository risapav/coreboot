# coreboot
To prepare COREBOOT bios


## Run coreboot-sdk environment

Run Docker inside project directory.

docker run --rm --privileged -it\
	--user "$(id -u):$(id -g)" \
	-v $PWD:/home/sdk \
	-w /home/sdk \
	coreboot/coreboot-sdk
