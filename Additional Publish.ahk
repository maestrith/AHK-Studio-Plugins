;menu Additional Publish
x:=ComObjActive("AHK-Studio")
script:=x.publish(1)
file:=x.current(2).file
otherinc:=execscript(Chr(34) file Chr(34))
includes:=""
for a,b in StrSplit(otherinc,"`n"){
	b:=RegExReplace(b,"i)" Chr(35) "include(again)?\s+|\R|" chr(34))
	SplitPath,b,,,ext
	if(!ext)
		continue
	if(FileExist(b)){
		FileRead,text,%b%
		includes.="`r`n" text
	}
}
Clipboard:=(script includes)
MsgBox,Script coppied to the Clipboard
ExecScript(Script, Wait:=true){
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec("AutoHotkey.exe /ilib * " script)
	exec.StdIn.Write(script)
	exec.StdIn.Close()
	if(Wait)
		return exec.StdOut.ReadAll()
}
return