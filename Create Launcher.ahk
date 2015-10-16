;menu Create Launcher
#SingleInstance,Force
x:=Studio()
path:=x.path(),filename:=x.file()
SetWorkingDir,%path%\
FileDelete,AHK Studio Launcher.exe
FileDelete,AHK Studio Launcher.ahk
script=Run,%filename%
FileAppend,%script%,AHK Studio Launcher.ahk
SplitPath,A_AhkPath,file,dirr
Loop,%dirr%\Ahk2Exe.exe,1,1
	file:=A_LoopFileFullPath
RunWait,%file% /in "AHK Studio Launcher.ahk" /icon "%path%\AHKStudio.ico"
FileDelete,AHK Studio Launcher.ahk
ExitApp