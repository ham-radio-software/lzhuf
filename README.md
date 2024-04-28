# lzhuf

C Implementation of lzhuf compression used with Winlink

* LZSS coded by Haruhiko OKUMURA
* Adaptive Huffman Coding coded by Haruyasu YOSHIZAKI
* Edited and translated to English by Kenji RIKITAKE

## Building And Testing

### Debian environments

Scripts are provided for building Debian packages in a chroot.
Generally linux packages should always be built in a chroot.

There are various quirks for building debian packages for all of these
distributions and versions what will not show up until you actually test
them.

In the debian/control file, while the current debhelper-compat is (= 13),
we need (= 12) for building Ubuntu 20.04 and earlier and (= 10) is needed
for building debian buster.  Also while the current Standards-version
is 4.5.1, the older 4.5.0 is needed for the same reasons.

Future distribution and version support may require either dropping older
versions from being pre-built, or may require having the build procedure
patch the debian/control file.

A Docker container is also used to allow building packages for
multiple Debian distributions and versions on any compatible docker host.

For building Raspbian packages on x86_64 systems, you need additional
packages.  On a debian platform, those packages are "qemu binfmt-support qemu-user-static".

After you install those platforms this docker command:

~~~bash
docker run --rm --privileged multiarch/qemu-user-static \
       --reset -p yes --credential yes
~~~

Test it with this command, the flags should be "OCF".

~~~bash
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
enabled
interpreter /usr/bin/qemu-aarch64-static
flags: OCF
offset 0
magic 7f454c460201010000000000000000000200b700
mask ffffffffffffff00fffffffffffffffffeffffff
~~~

For Raspbian Bookworm platforms, which are 64 bit, you need the docker platform
as "linux/arm64/v8".

For Raspbian Buster platforms, which are 32 bit, you need the docker platform as "linux/arm32/v7".

### Building all Debian x66_64 packages in a docker container

This takes a while to run on my system.

Properly building Linux packages involves building them in a chroot environment.
What the chroot environment is a clean minimal install of the target operating
system to make sure that any dependencies are known and that nothing in the
build is affected by system specific dependencies.

Your code, except for updates in the debian and packaging directories must
be in a git commit or it will not be used in the build.

It currently builds for:

* Ubuntu 18.04/20.04/22.04/24.04 on x86_64
* Debian bullseye/buster/bookworm on x86_64
* Debian buster on armv7l (Raspbian 32 bit compatible)
* Debian bookworm on arm64v8 (aarch64) (Raspbian 64 bit compatible)

~~~text
packaging/build_all_debian.sh
~~~

The resulting packages will be in the kits directory tree.
Each distribution will have its own directory, "debian" or "buster".

The .deb file is the debian package created.
The .dsc file and the two tarballs are what is considered the debian source
package for creating that specific .deb file.
The md5sum.txt contains the md5sums for these files.

~~~text
$ ls kits/ubuntu/jammy
lzhuf_2022.10.08_amd64.deb      lzhuf_2022.10.08.dsc
lzhuf_2022.10.08.debian.tar.xz  lzhuf_2022.10.08.orig.tar.gz
md5sum.txt
~~~

Installing after downloading or building the packages is done with the
apt-get command

~~~text
$ sudo apt-get install ./kits/debian/bullseye/lzhuf_2022.10.08-1.0_amd64.deb
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Note, selecting 'lzhuf' instead of './kits/debian/bullseye/lzhuf_2022.10.08-1.0_amd64.deb'
The following NEW packages will be installed:
  lzhuf
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 0 B/7,704 B of archives.
After this operation, 36.9 kB of additional disk space will be used.
Get:1 /mnt/aviary/home/malmberg/work/d-rats/lzhuf/kits/debian/bullseye/lzhuf_2022.10.08-1.0_amd64.deb lzhuf amd64 2022.10.08-1.0 [7,704 B]
Selecting previously unselected package lzhuf.
(Reading database ... 193355 files and directories currently installed.)
Preparing to unpack .../lzhuf_2022.10.08-1.0_amd64.deb ...
Unpacking lzhuf (2022.10.08-1.0) ...
Setting up lzhuf (2022.10.08-1.0) ...
Processing triggers for man-db (2.9.4-2) ...

$ command -v lzhuf
/usr/bin/lzhuf
~~~

### Generic Unix compatible environments

#### Build packages for Linux environments

* coreutils gcc make

#### Testing packages for Linux environments

* diffutils

#### Github contributing packages for Linux environments

* bash file git grep shellcheck codespell yamllint

On some platforms use ShellCheck for the package name.

### Building on Linux environments

~~~text
make clean
make
~~~

### Testing on Linux environments

On Microsoft Windows Msys2 or Cygwin, use lzhuf.exe instead of lzhuf.

~~~text
./lzhuf e tests/test_data.ref test_data.lzh
diff test_data.lzh tests/test_data.lzh_ref
./lzhuf d test_data.lzh test_data.src
diff test_data.src tests/test_data.ref
~~~

## Deployment in Linux style directory tree

On Microsoft Windows Msys2 or Cygwin, use lzhuf.exe instead of lzhuf.

~~~text
cp ./lzhuf /usr/local/bin/
~~~

If you are uploading the resulting binary, you should create an md5sum
of the image and that md5sum should be published on a different site
than on where the file is uploaded.

A repository on the ham-radio-software is planned to host these md5sum files.

Below, place platform with the distribution name, an underscore, and a version.
such as lzhuf_mac_johndoe_os_catalina_x86_64.txt

~~~text
md5sum /usr/local/bin/lzhuf > lzhuf_$USER_platform_$ARCH.txt
~~~

You may want to gzip the "lzhuf" image before uploading it.

### Microsoft Windows environments

#### Build packages for Microsoft Windows environments

* <https://visualstudio.microsoft.com/vs/community/>
* <https://wixtoolset.org/releases/>

#### Testing packages for Microsoft Windows environments

* fc utility built into Microsoft Windows.

#### Github contributing packages for Microsoft Windows environments

Recommend using a Linux environment on Microsoft Windows as above.

### Building on Microsoft Windows environments

These steps are done in the file packaging/build_msi.bat

Simply run open a command window and run:

~~~text
packaging/build_msi.bat
~~~

The above build_msi.bat script will create a kits/windows directory
with 3 files.  The .msi files are the 32 bit and 64 bit Intel x86 and x86_64
packages.

The lzhuf_md5sum.txt is generated with the certutil tool as documented
below.

### More details on building MSI packages

Below is a partial description of the script, it may not be as up to date
as the current script.

~~~text
msbuild lzhuf.vcxproj -t:build -p:Configuration=Release -p:Platform=Win32
msbuild lzhuf.vcxproj -t:build -p:Configuration=Release -p:Platform=x64make
~~~

### Testing on Microsoft Windows environments

On Windows, use lzhuf.exe instead of lzhuf.

~~~text
Release\lzhuf e tests\test_data.ref test_data.lzh

fc test_data.lzh tests/test_data.lzh_ref
Comparing files test_data.lzh and TESTS/TEST_DATA.LZH_REF
FC: no differences encountered

x64\Release\lzhuf d test_data.lzh test_data.src

fc test_data.src tests/test_data.ref
Comparing files test_data.src and TESTS/TEST_DATA.REF
FC: no differences encountered
~~~

## Creating a lzhuf msi package

First add Wix tools to your path

~~~text
.\msbuild_setup.bat
~~~

This is how the GUIDs in the WIX file were generated.
Unless you are creating new variants, you do not need to do this step.

~~~text
uuidgen
90df1c51-94ec-45b0-99e7-deae057c2482
~~~

Generate 32 bit and 64 bit MSI files from the WIX files in the repository.

~~~text
candle lzhuf_x86.wxs
Windows Installer XML Toolset Compiler version 3.11.2.4516
Copyright (c) .NET Foundation and contributors. All rights reserved.

lzhuf_x86.wxs

light.exe lzhuf_x86.wixobj
Windows Installer XML Toolset Linker version 3.11.2.4516
Copyright (c) .NET Foundation and contributors. All rights reserved.

candle -arch x64 lzhuf_x64.wxs
Windows Installer XML Toolset Compiler version 3.11.2.4516
Copyright (c) .NET Foundation and contributors. All rights reserved.

lzhuf_x64.wxs

light.exe lzhuf_x64.wixobj
Windows Installer XML Toolset Linker version 3.11.2.4516
Copyright (c) .NET Foundation and contributors. All rights reserved.

certutil -hashfile ./lzhuf_x64.msi MD5 > lzhuf_md5.txt

certutil -hashfile ./lzhuf_x86.msi MD5 >> lzhuf_md5.txt

if not exist ".\kits\" mkdir kits
if not exist ".\kits\windows\" mkdir kits\windows

move lzhuf_x64.msi kits\windows
move lzhuf_x86.msi kits\windows
move lzhuf_md5.txt kits\windows
~~~

The MSI files can be installed by clicking on them and can be uninstalled
via the "Programs and Features" application in the control panel.

### GitHub Pull requests

#### Git commit hook installation

This is used to do checks before committing a change for a pull request.

~~~text
cp tests/pre-commit .git/hooks
chmod 755 .git/hooks/pre-commit
~~~
