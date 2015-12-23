#SingleInstance,Force
;menu Run With Arduino
x:=Studio(),x.save,script:=x.current(2).file,settings:=x.get("settings")
/*
	rem:=settings.ssn("//arduino"),rem.ParentNode.RemoveChild(rem) ;clears prefs
*/
SplitPath,script,filename,,ext,nne
if(ext!="ino"){
	m("Only works with .ino files")
	ExitApp
}
if(!directory:=settings.ssn("//arduino/@path").text){
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
}
build.=nne
if(!FileExist(build)){
	FileCreateDir,%build%
	first:="`nFirst time compiling will take extra time"
}
SplashTextOn,200,100,Compiling Script,Please Wait...%first%
run="%directory%arduino-builder.exe" --hardware="%directory%hardware" --tools="%directory%tools-builder" --tools="%directory%hardware\tools" --fqbn=arduino:avr:uno --libraries="%A_MyDocuments%\Arduino\libraries" -build-path="%build%" "%script%"
create a console and attach it to the debug run to hide it
if(info:=RunWaitOne(run)){
	m(info)
	ExitApp
}
SplashTextOff
avr=%directory%hardware\tools\avr\
avrdude="%avr%bin\avrdude.exe" -p m328p -C "%avr%\etc\avrdude.conf" -c arduino -P \\.\%com% -D -U flash:w:%build%\%filename%.with_bootloader.hex:i
RunWait,%avrdude%
ExitApp
RunWaitOne(command) {
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec(command)
	return exec.Stderr.ReadAll()
}