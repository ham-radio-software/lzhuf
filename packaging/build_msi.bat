:: build_msi.bat

:: Builds lzhuf for Microsoft Windows

C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VSDevCmd.bat

:: C:\Program Files (x86)\WiX Toolset v3.11\bin
path|find /i "WiX Toolse"    >nul || ^
 set PATH=%PATH%;C:\Program Files (x86)\WiX Toolset v3.11\bin

msbuild lzhuf.vcxproj -t:build -p:Configuration=Release -p:Platform=Win32
msbuild lzhuf.vcxproj -t:build -p:Configuration=Release -p:Platform=x64

:: testing
Release\lzhuf e tests\test_data.ref test_data.lzh

fc test_data.lzh tests\test_data.lzh_ref

fc test_data.src tests\test_data.ref

candle lzhuf_x86.wxs

light.exe lzhuf_x86.wixobj

candle -arch x64 lzhuf_x64.wxs

light.exe lzhuf_x64.wixobj

:: We need md5sum for users to validate downloads

certutil -hashfile ./lzhuf_x64.msi MD5 > lzhuf_md5.txt

certutil -hashfile ./lzhuf_x86.msi MD5 >> lzhuf_md5.txt

if not exist ".\kits\" mkdir kits
if not exist ".\kits\windows\" mkdir kits\windows
del /q kits\windows\*

move lzhuf_x64.msi kits\windows
move lzhuf_x86.msi kits\windows
move lzhuf_md5.txt kits\windows
