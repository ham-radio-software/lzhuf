#! /bin/bash

# Debian chroot build.

# This script needs SUDO to run, and it is recommended that it run in
# docker container.

set -uex

# we need a git command
if ! command -v git; then
  sudo apt-get update && apt-get --assume-yes install git
fi
# We need the debchange command
if ! command -v debchange; then
  sudo apt-get update && apt-get --assume-yet install devscripts
fi

# This should be run from the base of the checked out repository
TOPDIR="${PWD}"

# For an actual project package build these should be overridden
: "${DEBEMAIL:=$(git config --get usr.email)}"
: "${DEBFULLNAME:=$(git config --get user.name)}"
export DEBEMAIL
export DEBFULLNAME
# don't fail this build because of shlib symbol differences
export DPKG_GENSYMBOLS_CHECK_LEVEL=1

# While this is originally for LZHUF make it generic.
# DEB_NAME must comply with Debian package naming.
: "${PACKAGE_NAME:=lzhuf}"
: "${DEB_NAME:=lzhuf}"

# The debian/changelog file controls the version, so we need to pull it out
change_ver="$(grep ^"$DEB_NAME" --max-count=1 debian/changelog)"
change_ver1="${change_ver%%)*}"
version="${change_ver1#*\(}"
tar_version="${version%-*}"

if [ ! -e /etc/os-release ]; then
  echo "Unsupported platform for Debian building!"
  exit 1
fi
# shellcheck source=/dev/null
source /etc/os-release
: "${ID:=unknown}"
if [ "$ID" == "unknown" ]; then
  echo "ID not in /etc/os-release!"
  exit 1
fi

# Debian may not have an ID_LIKE field
: "${ID_LIKE:=$ID}"
if [ "$ID_LIKE" != "debian" ]; then
  echo "This must be run on a Debian based system!"
  exit 1
fi

: "${VERSION_CODENAME:=unknown}"
if [ "$VERSION_CODENAME" == "unknown" ]; then
  echo "Unknown code name!"
  exit 1
fi

# Need to make sure coreutils is installed.
: "${ARCH:=$(arch)}"

# Allow overriding the default for the CHROOT
: "${CHROOT_CODENAME:=$VERSION_CODENAME}"
: "${CHROOT_ID:=$VERSION_ID}"

case $CHROOT_ID in
  ubuntu)
    UBUNTU_ARCHIVE="http://archive.ubuntu.com/ubuntu/"
    DISTRO_MIRROR="deb [arch=$ARCH] $UBUNTU_ARCHIVE $CHROOT_CODENAME universe"
    DISTRO_MIRROR+="|deb [arch=$ARCH] $UBUNTU_ARCHIVE $CHROOT_CODENAME-updates"
    DISTRO_MIRROR+=" main universe"
    ;;
  debian)
    DEBIAN_ARCHIVE1="http://deb.debian.org/debian/"
    DEBIAN_ARCHIVE2="http://security.debian.org/"
    DISTRO_MIRROR="deb $DEBIAN_ARCHIVE1 $CHROOT_CODENAME"
    DISTRO_MIRROR+=" main contrib non-free"
    if [ "$CHROOT_CODENAME" == "buster" ]; then
      # Buster is different, assuming and older layout
      DISTRO_MIRROR+="|deb $DEBIAN_ARCHIVE1 $CHROOT_CODENAME-updates main"
      DISTRO_MIRROR+="|deb $DEBIAN_ARCHIVE2 $CHROOT_CODENAME/updates"
      DISTRO_MIRROR+=" main contrib"
    else
      DISTRO_MIRROR+="|deb $DEBIAN_ARCHIVE2 $CHROOT_CODENAME-security"
      DISTRO_MIRROR+=" contrib"
    fi
    ;;
  raspbian)
    RASP_ARCHIVE1="http://raspbian.raspberrypi.org/raspbian/"
    RASP_ARCHIVE2="http://archive.raspberrypi.org/debian/"
    DISTRO_MIRROR="deb $RASP_ARCHIVE1 $CHROOT_CODENAME"
    DISTRO_MIRROR+=" main contrib non-free rpi"
    DISTRO_MIRROR+="!deb $RASP_ARCHIVE2 $CHROOT_CODENAME main"
    ;;
  *)
    echo "Unknown distribution $CHROOT_ID"
    exit 1
    ;;
esac

# The chroot build is in a temporary directory.
# For Continuous Integration use, we want that to be
# a subdirectory of this project instead of the default.
: "${DEB_TOP:=_topdir/BUILD}"
rm -rf ./"$DEB_TOP"
mkdir -p "$DEB_TOP"

DEB_BUILD="$DEB_TOP/$DEB_NAME-$version"

# A packaging build it assuming that it it pulling a specific build
# from a change control system.  Debian wants this format for that.
# Note that there must be an underscore befroe the version.
# Some packaging wrappers will simply fetch a tarball from the change
# control system.  Note that any existing "debian" directory in the
# tarball will be overwritten by the debian directory used for this
# run.
DEB_TARBASE="$DEB_TOP/${DEB_NAME}_$tar_version"
if [ ! -e "${DEB_TARBASE}.orig.tar.gz" ]; then
  # git config --global --add safe.directory /work
  git archive -o "${DEB_TARBASE}.orig.tar.gz" HEAD
fi

# A debian source consists of two files, the .dsc file and the upstream
# source tarball.
DEB_DSC="${DEB_NAME}_$version.dsc"

# Unpack the tarball we just made
rm -rf "./{$DEB_BUILD}/"*
mkdir -p "${DEB_BUILD}"
tar -C "${DEB_BUILD}" -xpf "$DEB_TARBASE.orig.tar.gz"

: "${TOPDIR:=$PWD}"

mkdir -p "${DEB_BUILD}/debian"

# Update DEB_BUILD from the local directory
cd "${TOPDIR}/" && \
  find debian -maxdepth 1 -type f \
  -exec cp '{}' "${DEB_BUILD}/"{} ';'
rm -f "${DEB_BUILD}/debian/compat"
if [ -e "${TOPDIR}/debian/source" ]; then
  cp -r "${TOPDIR}/debian/source" "${DEB_BUILD}/debian"
fi
if [ -e "${TOPDIR}/debian/local" ]; then
  cp -r "${TOPDIR}/debian/local" "${DEB_BUILD}/debian"
fi
if [ -e "${TOPDIR}/debian/examples" ]; then
  cp -r "${TOPDIR}/debian/examples" "${DEB_BUILD}/debian"
fi
if [ -e "${TOPDIR}/debian/upstream" ]; then
  cp -r "${TOPDIR}/debian/upstream" "${DEB_BUILD}/debian"
fi
if [ -e "${TOPDIR}/debian/tests" ]; then
  cp -r "${TOPDIR}/debian/tests" "${DEB_BUILD}/debian"
fi
rm -f "${DEB_BUILD}/debian/"*.ex "${DEB_BUILD}/debian/"*.EX
rm -f "${DEB_BUILD}/debian/"*.orig

cat "${DEB_BUILD}/debian/changelog"

pushd "${DEB_BUILD}"
  dpkg-buildpackage -S --no-sign --no-check-builddeps
popd

lintian -icv --color auto "${DEB_TOP}/${DEB_DSC}"

sudo pbuilder create \
         --distribution "$CHROOT_CODENAME" \
         --extrapackages "gnupg ca-certificates" \
         --othermirror "$DISTRO_MIRROR" \
         "$VERSION_CODENAME"

sudo DPKG_GENSYMBOLS_CHECK_LEVEL="${DPKG_GENSYMBOLS_CHECK_LEVEL:-4}" \
     pbuilder build --buildresult "$DEB_TOP" "$DEB_TOP/$DEB_DSC"

# The Ubuntu 22.04 builds are using a newer build than their
# lintian knows how to process so that error must be suppressed.
lintian -iEcv --pedantic --color auto \
    --suppress-tags malformed-deb-archive \
    "${DEB_TOP}/${DEB_NAME}_$version"*.deb

find . -name '*.dsc'
find . -name '*.deb'
find . -name '*.tar.gz'
