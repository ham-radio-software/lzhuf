# lzhuf

C Implementation of lzhuf compression used with Winlink

* LZSS coded by Haruhiko OKUMURA
* Adaptive Huffman Coding coded by Haruyasu YOSHIZAKI
* Edited and translated to English by Kenji RIKITAKE

## Building And Testing

### Tools needed

#### Build packages

* coreutils gcc make

#### Testing packages

* diffutils

#### Github contributing packages

* bash file git grep shellcheck codespell yamllint

On some platforms use ShellCheck for the package name.

### Building

~~~text
make clean
make
~~~

### Testing

On Windows, use lzhuf.exe instead of lzhuf.

~~~text
./lzhuf e tests/test_data.ref test_data.lzh
diff test_data.lzh test_data.lzh_ref
./lzhuf d test_data.lzh test_data.src
diff test_data.src tests/test_data.ref

## Deployment in Linux style directory tree

On Windows, use lzhuf.exe instead of lzhuf.

~~~text
cp ./lzhuf /usr/local/bin/
~~~

### GitHub Pull requests

#### Git commit hook installation

cp tests/pre-commit .git/hooks
chmod 755 .git/hooks/pre-commit
