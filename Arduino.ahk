#SingleInstance,Force
;menu Run With Arduino
DetectHiddenWindows,On
x:=Studio(1),x.save,script:=x.current(2).file,settings:=x.get("settings")
/*
	rem:=settings.ssn("//arduino"),rem.ParentNode.RemoveChild(rem) ;clears prefs
*/
SplitPath,script,filename,,ext,nne
if(ext!="ino"){
	m("Only works with .ino files")
	ExitApp
}if(!directory:=settings.ssn("//arduino/@path").text){
	RegRead,install,HKCR,Arduino file\shell\edit\command
	RegExMatch(install,"U)\x22(.*)\x22",install)
	SplitPath,install1,,dir
	dir.="\",new:=settings.add("arduino"),att(new,{path:dir}),directory:=dir
}if((!build:=settings.ssn("//arduino/@build").text)||!FileExist(build)){
	FileSelectFolder,build,,3,Please select a folder to save your compiled sketches to
	if(ErrorLevel||!FileExist(build)){
		m("Unable to continue without a build directory")
		ExitApp
	}build.="\",new:=settings.add("arduino"),att(new,{build:build})
}if(!com:=settings.ssn("//arduino/@com").text){
	InputBox,com,Arduino Com Port,Enter the name of the COM port that your Arduino uses (EG. COM3)
	if(!RegExMatch(com,"COM\d+")){
		m("Syntax MUST be COM[number] case sensitive")
		ExitApp
	}
	new:=settings.add("arduino"),att(new,{com:com})
}build.=nne
if(!FileExist(build)){
	FileCreateDir,%build%
	first:="`nFirst time compiling will take extra time"
}
SplashTextOn,200,100,Compiling Script,Please Wait...%first%
run="%directory%arduino-builder.exe" --hardware="%directory%hardware" --tools="%directory%tools-builder" --tools="%directory%hardware\tools" --fqbn=arduino:avr:uno --libraries="%A_MyDocuments%\Arduino\libraries" -build-path="%build%" "%script%"
if(info:=RunWaitOne(run)){
	m(info)
	ExitApp
}
SplashTextOff
avr=%directory%hardware\tools\avr\
SplitPath,filename,fnme,fdir
qu:=Chr(34)
SplashTextOn,200,100,Flashing Script,Please Wait...
output:=RunWaitOne(qu avr "bin\avrdude.exe" qu " -p m328p -C " qu avr "etc\avrdude.conf" qu " -c arduino -P \\.\" com " -D -U flash:w:" qu build "\" fnme qu ".with_bootloader.hex:i")
SplashTextOff
Dwell:=InStr(output,"avrdude.exe done.  Thank you.")?1:0
MsgBox,,AHK Studio,%output%,%dwell%
ExitApp
RunWaitOne(command) {
	WinGet,pid,pid,ahk_id%A_ScriptHwnd%
	DetectHiddenWindows, on
	Run,%comspec% /k,,Hide UseErrorLevel, cPid
	WinWait, ahk_pid %cPid%,,10
	DllCall("AttachConsole","uint",cPid),hCon:=DllCall("CreateFile","str","CONOUT$","uint",0xC0000000,"uint",7,"uint",0,"uint",3,"uint",0,"uint",0),shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec(command),DllCall("CloseHandle","uint",hCon),DllCall("FreeConsole")
	if(info:=exec.Stderr.ReadAll()){
		return info
	}else{
		return exec.stdout.ReadAll()
	}
}
