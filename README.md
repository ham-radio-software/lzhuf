# lzhuf

C Implementation of lzhuf compression used with Winlink

* LZSS coded by Haruhiko OKUMURA
* Adaptive Huffman Coding coded by Haruyasu YOSHIZAKI
* Edited and translated to English by Kenji RIKITAKE

## Building And Testing Unix compatible

On Microsoft Windows Msys2 Mingw64, use lzhuf.exe instead of lzhuf.

### Tools needed for Linux environments

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

~~~text
./lzhuf e tests/test_data.ref test_data.lzh
diff test_data.lzh tests/test_data.lzh_ref
./lzhuf d test_data.lzh test_data.src
diff test_data.src tests/test_data.ref
~~~

## Deployment in Linux style directory tree

~~~text
cp ./lzhuf /usr/local/bin/
~~~

## Building on Microsoft Windows Native

### Tools needed for Microsoft Windows environments

#### Build packages for Microsoft Windows environments

* <https://visualstudio.microsoft.com/vs/community/>
* <https://wixtoolset.org/releases/>

### Testing packages for Microsoft Windows environments

* fc utility built into Microsoft Windows.

#### Github contributing packages for Microsoft Windows environments

Recommend using a Linux environment on Microsoft Windows as above.

### Building on Microsoft Windows environments

~~~bat
"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VSDevCmd.bat"
~~~

Then you can built the win32 and x64 release targets.

~~~bat
msbuild lzhuf.vcxproj -t:build -p:Configuration=Release -p:Platform=Win32
msbuild lzhuf.vcxproj -t:build -p:Configuration=Release -p:Platform=x64
~~~

The Win32 build is put in the Release folder.

The x64 build is put in the x64\Release folder.

### Microsoft Windows Testing

~~~bat
W:\work\d-rats\lzhuf>Release\lzhuf e tests\test_data.ref test_data.lzh

W:\work\d-rats\lzhuf>fc test_data.lzh tests/test_data.lzh_ref
Comparing files test_data.lzh and TESTS/TEST_DATA.LZH_REF
FC: no differences encountered

W:\work\d-rats\lzhuf>x64\Release\lzhuf d test_data.lzh test_data.src

W:\work\d-rats\lzhuf>fc test_data.src tests/test_data.ref
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
~~~

The MSI files can be installed by clicking on them and can be uninstalled
via the "Programs and Features" application in the control panel.

## GitHub Pull requests

### Git commit hook installation

cp tests/pre-commit .git/hooks
chmod 755 .git/hooks/pre-commit
