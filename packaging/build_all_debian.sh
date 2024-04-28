#!/bin/bash

set -uex

# While this is originally for LZHUF make it generic.
# DEB_NAME must comply with Debian package naming.
: "${PACKAGE_NAME:=lzhuf}"
: "${DEB_NAME:=lzhuf}"
export PACKAGE_NAME
export DEB_NAME

do_packaging () {
  packaging/build_debian.sh
  kit_dir="kits/${ARCH}${CHROOT_ID}/${CHROOT_CODENAME}"
  mkdir -p "$kit_dir"
  rm -f "./$kit_dir"/*
  mv _topdir/BUILD/*.dsc "$kit_dir"
  mv _topdir/BUILD/*.deb "$kit_dir"
  mv _topdir/BUILD/*.tar.* "$kit_dir"
  md5sum "$kit_dir"/* > "$kit_dir/${DEB_NAME}_md5sum.txt"
}

arch="$(arch)"

# All x86_64 packaging
if [ "$arch" == x86_64 ]; then
  # Docker File to use
  ARCH=""
  DISTRO_NAME=ubuntu
  DISTRO_VERSION=22.04

  CHROOT_ID="${DISTRO_NAME}"

  export DISTRO_NAME
  export DISTRO_VERSION
  export CHROOT_CODENAME
  export CHROOT_ID
  export ARCH

  # Docker image for 22.04 will not work on Ubuntu 20.04
  # We can use the ubuntu 20.04 image for chroot builds
  # for all ubuntu amd64 targets.
  # DISTRO_VERSION=24.04
  CHROOT_CODENAME=noble
  do_packaging

  # DISTRO_VERSION=22.04
  CHROOT_CODENAME=jammy
  do_packaging

  # DISTRO_VERSION=20.04
  CHROOT_CODENAME=focal
  do_packaging

  # DISTRO_VERSION=18.04
  CHROOT_CODENAME=bionic
  do_packaging

  # We have to use the debian docker image for building
  # for Debian based distros like Anti-X linux.
  DISTRO_NAME=debian
  DISTRO_VERSION=bookworm
  CHROOT_ID="${DISTRO_NAME}"

  # DISTRO_NAME=debian
  # DISTRO_VERSION=12
  CHROOT_CODENAME=bookworm
  do_packaging

  # DISTRO_NAME=debian
  # DISTRO_VERSION=11
  CHROOT_CODENAME=bullseye
  do_packaging

  # DISTRO_NAME=debian
  DISTRO_VERSION=10
  CHROOT_CODENAME=buster
  do_packaging

  # Rasbian Bookworm 64 bit
  ARCH="arm64v8/"
  CHROOT_CODENAME=bookworm
  do_packaging

  # Rasbian Buster 32 bit
  ARCH="arm32v7/"
  CHROOT_CODENAME=buster
  do_packaging

fi
