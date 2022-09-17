# lzhuf

C Implementation of lzhuf compression used with Winlink

* LZSS coded by Haruhiko OKUMURA
* Adaptive Huffman Coding coded by Haruyasu YOSHIZAKI
* Edited and translated to English by Kenji RIKITAKE

## Building And Testing Unix compatible

On Microsoft Windows Msys2 Mingw64, use lzhuf.exe instead of lzhuf.

### Tools needed

#### Build packages

* coreutils gcc make

#### Testing packages

* diffutils

#### Packages for contributing to GitHub Pull Requests

* bash file git grep shellcheck codespell yamllint

On some platforms use ShellCheck for the package name.

### Building

~~~text
make clean
make
~~~

### Testing

~~~text
./lzhuf e tests/test_data.ref test_data.lzh
diff test_data.lzh tests/test_data.lzh_ref
./lzhuf d test_data.lzh test_data.src
diff test_data.src tests/test_data.ref

## Deployment in Linux style directory tree

~~~text
cp ./lzhuf /usr/local/bin/
~~~

## Building on Microsoft Windows Native

### Microsoft Windows Native Tools needed

* Microsoft Visual Studio Community Edition or better

### Microsoft Windows Building

Need to launch a command prompt window.

Set your directory to where the lzhuf source is checked out.

MSbuild does not seem to run on PowerShell for Windows 7.

You have to add the path to MSbuild using a script provided by Visual Studio.

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

## GitHub Pull requests

### Git commit hook installation

cp tests/pre-commit .git/hooks
chmod 755 .git/hooks/pre-commit
