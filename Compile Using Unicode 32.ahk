;menu Compile Using Unicode 32
x:=ComObjActive("AHK-Studio")
tempdir:=A_MyDocuments "\temp"
FileDelete,%tempdir%\temp.upload
name:="myfile"
if(!FileExist(tempdir))
	FileCreateDir,%tempdir%
SplitPath,A_AhkPath,file,dirr
Loop,%dirr%\Ahk2Exe.exe,1,1
	file:=A_LoopFileFullPath
FileAppend,% x.publish(1),%tempdir%\temp.upload
SplashTextOn,200,100,Compiling,Please wait.
RunWait,%file% /in "%tempdir%\temp.upload" /out "%tempdir%\%name%.exe" /bin "%dirr%\Compiler\Unicode 32-bit.bin"
If(FileExist("upx.exe")){
	SplashTextOn,,50,Compressing EXE,Please wait...
	RunWait,upx.exe -9 "%dir%\%name%.exe",,Hide
}
SplashTextOff
Run,%tempdir%
return