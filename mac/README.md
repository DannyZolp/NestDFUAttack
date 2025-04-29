# MacOS helper scripts

## `make_sensitive.sh`


Commonly, MacOS volumes are case-insensitive, which means that you can have two files with the same name but different cases. This is a problem for us because the NestDFUAttack repository has numerous files which differ only by case, and hence cannot be used on a case-insensitive volume.

Create a case-sensitive dmg filesystem image, mount it at `/Volumes/CaseSensitiveVolume`, and clone the [rick/NestDFUAttack](https://github.com/rick/NestDFUAttack) repository fork into it.

```bash
./make_sensitive.sh
```

## Building the Docker image and rebuilding the NestDFUAttack distribution

The original NestDFUAttack distribution is based on Ubuntu 12.04, which is fairly out of date (and accessing the apt repositories proved to be a bit difficult). Here we base the more modern build on Ubuntu 18.04 as a Docker image.  There are a couple of tweaks to the kernel build system which were needed to get it to fully compile.

Rebuilding the NestDFUAttack distribution:

```bash
# Mac: cd /Volumes/CaseSensitiveVolume/NestDFUAttack
docker build -t nest-build .
docker run -it -v $(pwd):/workspace nest-build /workspace/Dev/build.sh
```



