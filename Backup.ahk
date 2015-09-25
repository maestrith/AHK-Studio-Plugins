;menu Backup
#SingleInstance,Force
x:=Studio()
current:=x.current(2).file
SplitPath,current,,dir
FileSelectFolder,folder,,,Select a folder to backup your project
folder.=SubStr(folder,0)="\"?"":"\"
if(ErrorLevel||folder="")
	ExitApp
Loop,%dir%\*.*,0,1
{
	if(InStr(A_LoopFileDir,dir "\backup"))
		Continue
	newdir:=RegExReplace(A_LoopFileDir,"\Q" dir "\E\\?")
	if(!FileExist(folder newdir)){
		FileCreateDir,% folder newdir
		newdir.="\"
	}
	SplitPath,A_LoopFileName,filename
	FileCopy,%A_LoopFileFullPath%,% folder newdir filename,1
}
m("done")
ExitApp
return
t(x*){
	for a,b in x
		list.=b "`n"
	Tooltip,% list
}