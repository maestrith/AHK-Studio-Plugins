;menu Compile Using Unicode 64
x:=Studio()
tempdir:=A_MyDocuments "\temp"
FileDelete,%tempdir%\temp.upload
main:=x.Current(2).file
SplitPath,main,,dir,,name
SplitPath,A_AhkPath,file,dirr
Loop,%dirr%\Ahk2Exe.exe,1,1
	file:=A_LoopFileFullPath
if(!FileExist(tempdir "\temp"))
	FileCreateDir,%tempdir%\temp
FileDelete,%tempdir%\temp.upload
FileAppend,% x.Publish(1),%tempdir%\temp.upload
SplashTextOn,200,100,Compiling,Please wait.
Loop,%dir%\*.ico
	icon:=A_LoopFileFullPath
if(icon)
	add=/icon "%icon%"
RunWait,%file% /in "%tempdir%\temp.upload" /out "%tempdir%\%name%.exe" %add% /bin "%dirr%\Compiler\Unicode 64-bit.bin"
If(FileExist("upx.exe")){
	SplashTextOn,,50,Compressing EXE,Please wait...
	RunWait,upx.exe -9 "%dir%\%name%.exe",,Hide
}
SplashTextOff
FileDelete,%tempdir%\temp.upload
Run,%tempdir%
return
