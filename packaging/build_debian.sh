#!/bin/bash

set -uex

# Create a tarball for the source directory

: "${DISTRO_NAME:=ubuntu}"
: "${DISTRO_VERSION:=20.04}"

# Allow overriding the default for the CHROOT
: "${CHROOT_CODENAME:=$VERSION_CODENAME}"
: "${CHROOT_ID:=$DISTRO_NAME}"

# Build a docker image to use for the build.
# give it a tag so that we can run it later as a container.
docker build \
  --tag "chroot_$DISTRO_NAME:$DISTRO_VERSION" \
  --build-arg BASE_DISTRO="$DISTRO_NAME:$DISTRO_VERSION" \
  --build-arg UID="$UID" \
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
  -e "DEBEMAIL=$DEBEMAIL" \
  -e "DEBFULLNAME=$DEBFULLNAME" \
  -e "CHROOT_CODENAME=$CHROOT_CODENAME" \
  -e "CHROOT_ID=$CHROOT_ID" \
  "chroot_$DISTRO_NAME:$DISTRO_VERSION" \
  /work/packaging/debian_chrootbuild.sh
