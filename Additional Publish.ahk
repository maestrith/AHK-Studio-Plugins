;menu Additional Publish
x:=ComObjActive("AHK-Studio"),script:=x.publish(1),file:=x.current(2).file,otherinc:=execscript(Chr(34) file Chr(34)),includes:=""
for a,b in StrSplit(otherinc,"`n"){
	b:=RegExReplace(b,"i)" Chr(35) "include(again)?\s+|\R|" chr(34))
	SplitPath,b,,,ext
	if(!ext){
		dir:=b
		continue
	}
	if(FileExist(b)){
		FileRead,text,%b%
		pos:=1
		while,RegExMatch(text,"Oim`n)(^" Chr(35) "include[,| ](.*))$",found,pos){
			StringReplace,text,text,% found.1
			found:=RegExReplace(found.2,"i)" Chr(35) "include(again)?\s+|\R|" chr(34))
			if(InStr(found,"<")){
				incfile:=dir RegExReplace(found,"\<|\>") ".ahk"
				FileRead,inc,%incfile%
				includes.="`r`n" inc
			}else
				x.m("Ask maestrith nicely to add in support for #include filename")
			pos:=found.Pos(1)+found.len(1)
		}
		includes.="`r`n" text
	}
}
Clipboard:=(script includes)
x.TrayTip(Script copied to the Clipboard)
ExecScript(Script, Wait:=true){
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec("AutoHotkey.exe /ilib * " script)
	exec.StdIn.Write(script)
	exec.StdIn.Close()
	if(Wait)
		return exec.StdOut.ReadAll()
}
return