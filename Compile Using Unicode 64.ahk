;menu Compile Using Unicode 64
x:=Studio(),x.Save()
main:=x.Current(2).file
SplitPath,main,,dir,,name
SplitPath,A_AhkPath,file,dirr
Loop,%dirr%\Ahk2Exe.exe,1,1
	file:=A_LoopFileFullPath
SplashTextOn,200,100,Compiling,Please wait.
Loop,%dir%\*.ico
	icon:=A_LoopFileFullPath
if(icon)
	add=/icon "%icon%"
RunWait,%file% /in "%main%" /out "%dir%\%name%.exe" %add% /bin "%dirr%\Compiler\Unicode 64-bit.bin"
If(FileExist("upx.exe")){
	SplashTextOn,,50,Compressing EXE,Please wait...
	RunWait,upx.exe -9 "%dir%\%name%.exe",,Hide
}
SplashTextOff
Run,%dir%
ExitApp
