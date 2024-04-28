#!/bin/bash

set -uex

# Create a tarball for the source directory

: "${DISTRO_NAME:=ubuntu}"
: "${DISTRO_VERSION:=20.04}"
: "${ARCH:=}"

# Allow overriding the default for the CHROOT
: "${CHROOT_CODENAME:=$VERSION_CODENAME}"
: "${CHROOT_ID:=$DISTRO_NAME}"

# Yes you can build packages for Raspian
platform="linux/amd64/v1"
if [ "$ARCH" == "arm64v8/" ]; then
    platform="linux/arm64/v8"
fi
if [ "$ARCH" == "arm32v7/" ]; then
    platform="linux/arm/v7"
fi

DOCKER_DEFAULT_PLATFORM="$platform"
export DOCKER_DEFAULT_PLATFORM
# Build a docker image to use for the build.
# give it a tag so that we can run it later as a container.
docker build --platform="$platform" \
  --tag "chroot_${ARCH%%/}$DISTRO_NAME:$DISTRO_VERSION" \
  --build-arg BASE_DISTRO="${ARCH}$DISTRO_NAME:$DISTRO_VERSION" \
  --build-arg UID="$UID" \
  --build-arg PLATFORM="$platform" \
  --file packaging/Dockerfile.debian_chroot \
  .

# For an actual project package build these should be overridden
: "${DEBEMAIL:=$(git config --get usr.email)}"
: "${DEBFULLNAME:=$(git config --get user.name)}"
export DEBEMAIL
export DEBFULLNAME

docker run --rm \
  --cap-add SYS_ADMIN \
  --privileged \
  --volume="$PWD":/work \
  --workdir=/work \
  --user="$UID" \
  --platform="$platform" \
  -e "DEBEMAIL=$DEBEMAIL" \
  -e "DEBFULLNAME=$DEBFULLNAME" \
  -e "CHROOT_CODENAME=$CHROOT_CODENAME" \
  -e "CHROOT_ID=$CHROOT_ID" \
  "chroot_${ARCH%%/}$DISTRO_NAME:$DISTRO_VERSION" \
  /work/packaging/debian_chrootbuild.sh
