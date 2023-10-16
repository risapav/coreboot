# coreboot
To prepare COREBOOT bios


## Prepare Tools

### To prepare coreboot TAG 4.21, within dir run 

```sh
./build.sh -t 4.21
```

### Prepare docker SDK

```sh
./build.sh -bd
```


## Run coreboot-sdk environment

Run Docker inside project directory.

```sh
docker run --rm --privileged -it\
	--user "$(id -u):$(id -g)" \
	-v $PWD:/home/sdk \
	-w /home/sdk \
	coreboot/coreboot-sdk
```  
  
  
## Compile project lenovo/x220

```sh
./build.sh x220
```
