#SingleInstance,Force
;menu Debug Current Script
x:=Studio()
global files,v,displaymsg,settings,cexml
settings:=x.get("Settings"),cexml:=x.get("cexml")
v:=x.get("v")
OnExit,exit
files:=x.get("files")
Debug_Current_Script()
return
exit:
debug.send("stop")
ExitApp
return
97Close(){
	return
}
97Escape(){
	Gui,97:Destroy
	return
}
class debug{
	static socket
	__New(){
		if(this.socket){
			debug.Send("stop")
			sleep,500
			this.disconnect()
		}
		sock:=-1
		DllCall("LoadLibrary","str","ws2_32","ptr"),VarSetCapacity(wsadata,394+A_PtrSize),DllCall("ws2_32\WSAStartup","ushort",0,"ptr",&wsadata),DllCall("ws2_32\WSAStartup","ushort",NumGet(wsadata,2,"ushort"),"ptr",&wsadata),OnMessage(0x9987,"Sock"),socket:=sock
		next:=debug.addrinfo(),sockaddrlen:=NumGet(next+0,16,"uint"),sockaddr:=NumGet(next+0,16+(2*A_PtrSize),"ptr"),socket:=DllCall("ws2_32\socket","int",NumGet(next+0,4,"int"),"int",1,"int",6,"ptr")
		if(DllCall("ws2_32\bind","ptr",socket,"ptr",sockaddr,"uint",sockaddrlen,"int")!=0)
			return m(DllCall("ws2_32\WSAGetLastError"))
		DllCall("ws2_32\freeaddrinfo","ptr",next),DllCall("ws2_32\WSAAsyncSelect","ptr",socket,"ptr",A_ScriptHwnd,"uint",0x9987,"uint",0x29),ss:=DllCall("ws2_32\listen","ptr",socket,"int",32),debug.socket:=socket,v.dbgsock:=socket
		v.ddd:=this
	}
	addrinfo(){
		VarSetCapacity(hints,8*A_PtrSize,0)
		for a,b in {6:8,1:12}
			NumPut(a,hints,b)
		DllCall("ws2_32\getaddrinfo",astr,"127.0.0.1",astr,"9000","uptr",hints,"ptr*",results)
		return results
	}
	Run(filename){
		global x
		v.debugfilename:=filename
		new debug()
		SetTimer,runn,50
		return
		runn:
		SetTimer,runn,Off
		filename:=v.debugfilename
		SplitPath,filename,,dir
		Run,"%A_AhkPath%" /debug "%filename%",%dir%,,pid
		v.pid:=pid
		SetTimer,cee,-800
		return
		cee:
		if(WinExist("ahk_pid" v.pid)){
			ControlGetText,text,Static1,% "ahk_pid" v.pid
			sc:=x.sc()
			info:=striperror(text,v.debugfilename)
			if(info.line&&info.file){
				x.call("SetPos",{file:info.file,line:info.line})
			}
		}
		return
	}
	encode(text){ ;original http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
		if(text="")
			return
		cp:=0,VarSetCapacity(rawdata,StrPut(text,"utf-8")),sz:=StrPut(text,&rawdata,"utf-8")-1,DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"ptr",0,"uint*",cp),VarSetCapacity(str,cp*(A_IsUnicode?2:1)),DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"str",str,"uint*",cp)
		return str
	}
	decode(string){ ;original http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
		if(string="")
			return
		DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",0,"uint*",cp:=0,"ptr",0,"ptr",0),VarSetCapacity(bin,cp),DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",&bin,"uint*",cp,"ptr",0,"ptr",0)
		return StrGet(&bin,cp,"utf-8")
	}
	Off(){
		global x
		for a,b in [10002,10003,10004]
			toolbar.list.10002.setstate(b,16)
		for a,b in [10000,10001]
			toolbar.list.10002.setstate(b,4)
		v.dbgsock:=0,x.settimer("rsize")
		;m("send the off signals to the toolbar")
		;ExitApp
	}
	On(){
		for a,b in [10002,10003,10004]
			toolbar.list.10002.setstate(b,4)
		for a,b in [10000,10001]
			toolbar.list.10002.setstate(b,16)
	}
	register(){
		DllCall("ws2_32\WSAAsyncSelect","ptr",debug.socket,"ptr",A_ScriptHwnd,"uint",0x9987,"uint",0x29)
	}
	disconnect(){
		debug.send("stop")
		Sleep,300
		DllCall("ws2_32\WSAAsyncSelect","uint",debug.socket,"ptr",A_ScriptHwnd,"uint",0,"uint",0),DllCall("ws2_32\closesocket","uint",debug.socket,"int"),DllCall("ws2_32\WSACleanup"),debug.socket:="",debug.Off()
	}
	accept(){
		if((sock:=DllCall("ws2_32\accept","ptr",debug.socket,"ptr",0,"int",0,"ptr"))!=-1)
			debug.socket:=sock,debug.register()
		Else
			debug.disconnect()
	}
	Send(message){
		message.=Chr(0),len:=strlen(message),VarSetCapacity(buffer,len),ll:=StrPut(message,&buffer,"utf-8"),DllCall("ws2_32\send","ptr",debug.socket,uptr,&buffer,"int",ll,"int",0,"cdecl")
	}
}
debug(text){
	Gui,55:Destroy
	Gui,55:Add,Edit,w800 h800 -Wrap,%text%
	Gui,55:Show
}
Debug_Current_Script(){
	global x
	if(x.current(2).file=A_ScriptFullPath||x.current(2).file=x.file()){
		m("Can not debug AHK Studio using AHK Studio.")
		ExitApp
	}
	x.save(),debug.Run(x.current(2).file)
}
display(){
	static recieve:=new xml("recieve"),total,width,flan
	global x
	start:=1,store:=""
	if(!v.debug.sc)
		x.debugwindow()
	width:=v.debug.2276(5,"A")
	ControlGetPos,,,,h,,% "ahk_id" v.debug.sc
	if(h=0)
		x.settimer("rsize")
	while,displaymsg.1{
		store:=displaymsg.pop(),recieve.xml.loadxml(store)
		if(info:=recieve.ssn("//stream[@type='stderr']")){
			sc:=v.debug
			info:=debug.decode(info.text),total.=info "`n"
			sc.2003(sc.2006,info "`n"),sc.2025(sc.2006)
			sc.2242(0,StrLen(sc.2166(sc.2006))*width+width)
			in:=striperror(info,v.debugfilename)
			if(in.file&&in.line){
				x.call("SetPos",{file:in.file,line:in.line})
				sc.2200(sc.2008,recieve[])
			}
			return
		}
		if(init:=recieve.ssn("//init")){
			v.afterbug:=[],ad:=["stdout -c 2","stderr -c 2"],ea:=settings.ea("//features")
			for a,b in ["max_depth","max_children"]
				value:=ea[b]?ea[b]:1,ad.Insert("feature_set -n " b " -v " value)
			bp:=cexml.sn("//main[@file='" x.current(2).file "']/descendant::*[@type='Breakpoint']")
			while,bb:=bp.item[A_Index-1],bpea:=xml.ea(bb)
				ad.Insert("breakpoint_set -t line -f " bpea.filename " -n" bpea.line)
			if v.connect
				ad.Insert("run"),v.connect:=0
			for a,b in ad
				v.afterbug.Insert(b)
			SetTimer,afterbug,200
			debug.On()
		}
		if(recieve.ssn("//property")){
			if property:=recieve.sn("//property"){
				if property.length>1000
					ToolTip,Compiling List Please Wait...,350,150
				varbrowser(),list:=[],variablelist:=[],value:=[],object:=recieve.sn("//response/property")
				Gui,97:Default
				GuiControl,97:-Redraw,SysTreeView321
				TV_Delete()
				while,oo:=object.item[A_Index-1]{
					ea:=xml.ea(oo),value:=debug.decode(oo.text),list[ea.fullname]:=TV_Add(ea.fullname a:=ea.type="object"?"":" = " value)
					if(ea.type!="object")
						variablelist[list[ea.fullname]]:={value:value,variable:ea.fullname}
					descendant:=sn(oo,"descendant::*")
					while,des:=descendant.item[A_Index-1]{
						ea:=xml.ea(des),value:=debug.decode(des.text),list[ea.fullname]:=TV_Add(ea.fullname a:=ea.type="object"?"":" = " value,list[prev:=SubStr(ea.fullname,1,InStr(ea.fullname,".",0,0)-1)],"Sort")
						if(ea.type!="object")
							variablelist[list[ea.fullname]]:={value:value,variable:ea.fullname}
					}
				}
				v.variablelist:=variablelist,debug.Send("run")
				GuiControl,97:+Redraw,SysTreeView321
				return t()
			}
		}else if info:=recieve.ssn("//stream"){
			disp:=debug.decode(info.text),stream:=1
		}else if command:=recieve.ssn("//response"){
			if recieve.sn("//response").length>1
				m("more info")
			ea:=recieve.ea(command)
			if(ea.command="stack_get"){
				;RegExReplace(RegExReplace(ea.filename,"\Qfile:///\E"))
				stack:=recieve.ea(flan:=ssn(command,"descendant-or-self::stack"))
				file:=RegExReplace(RegExReplace(URIDecode(stack.filename),"\Qfile:///\E"),"\/","\")
				x.call("SetPos",{file:file,line:stack.lineno-1})
			}
			if(ea.status="stopped"&&ea.command="run"&&ea.reason="ok")
				debug.Off()
			disp:="Command:"
			if(ea.status="break")
				debug.send("stack_get")
			for a,b in ea
				if(a&&b)
					disp.=((A_Index>1)?" , ":"")a " = " Chr(34) b Chr(34)
			info:=disp
		}
		disp:=disp?disp:store
		if(disp){
			total.=disp "`n"
			sc:=v.debug
			sc.2003(sc.2006,info "`n"),sc.2025(sc.2006)
		}
		if(stream){
			stream:=0
			return disp
		}
		return
		disp:=recieve[],store:=disp?disp:store
		return sock
	}
	debug.send("detach")
	SetTimer,closeconn,400
	return
	closeconn:
	SetTimer,closeconn,Off
	debug.disconnect() ;,hwnd({rem:99})
	return
	afterbug:
	debug.Send(v.afterbug.1),v.afterbug.Remove(1)
	if !v.afterbug.1
		SetTimer,afterbug,Off
	return
}
listvars(){
	if !debug.socket
		return m("Currently no file being debugged"),debug.off()
	debug.send("context_get -c 1")
	/*
		;this can get a single value.
		so when the user clicks on a top level item, have it get it's children
		debug.send("feature_set -n max_depth -v 1")
		Sleep,50
		debug.send("feature_set -n max_children -v 200")
		Sleep,50
		debug.send("property_get -n xml")
	*/
}
Receive(){
	;Thank you Lexikos and fincs http://ahkscript.org/download/tools/DBGP.ahk
	Critical
	socket:=debug.socket
	while,DllCall("ws2_32\recv","ptr",socket,"char*",c,"int",1,"int",0){
		if c=0
			break
		length.=Chr(c)
	}
	VarSetCapacity(packet,++length,0)
	received:=0,text:=""
	While,(received<length){
		r:=DllCall("ws2_32\recv","ptr",socket,"ptr",&packet+received,"int",length-received,"int",0)
		if(r<1){
			error:=DllCall("GetLastError")
			return m(r,socket,length,received,"An error occured",error,"Possible reasons for the error:","1.  Sending OutputDebug faster than 1ms per message","2.  Max_Depth or Max_Children value too large")
		}
		received+=r
	}
	Critical,Off
	if(!IsObject(displaymsg))
		displaymsg:=[]
	if(info:=StrGet(&packet,"utf-8")){
		displaymsg.push(info)
		SetTimer,display,-10
	}
}
Sock(info*){
	Sleep,1
	if(info.3=0x9987){
		if(info.2&0xFFFF=1)
			receive()
		if(info.2&0xffff=8)
			debug.accept()
		if(info.2&0xFFFF=32)
			debug.disconnect()
	}
}
striperror(text,fn){
	for a,b in StrSplit(text,"`n"){
		if RegExMatch(b,"i)^Error in")
			filename:=StrSplit(b,Chr(34)).2
		if InStr(b,"error at line"){
			RegExMatch(b,"(\d+)",line),debug.disconnect()
			filename:=StrSplit(b,Chr(34)).2
		}
		if InStr(b,"--->")
			RegExMatch(b,"(\d+)",line),debug.disconnect()
	}
	filename:=filename?filename:fn
	return {file:filename,line:line-1}
}
VarBrowser(){
	static newwin,treeview
	if(!WinExist(newwin.id))
		newwin:=new GUIKeep(97),newwin.add("TreeView,w300 h400 gvalue vtreeview AltSubmit hwndtreeview,,wh","Button,gReloadVar,Reload Variables,y"),newwin.show("Variable Browser")
	return
	value:
	global x
	if A_GuiEvent!=Normal
		return
	if value:=v.variablelist[A_EventInfo]{
		ei:=A_EventInfo,newvalue:=x.call("InputBox",x.sc().sc,"Current value for " value.variable,"Change value for " value.variable,value.value)
		if ErrorLevel
			return
		debug.send("property_set -n " value.variable " -- " debug.encode(newvalue)),TV_Modify(ei,"",value.variable " = " newvalue)
	}
	return
	ReloadVar:
	Gui,97:Default
	TV_Delete(),ListVars()
	return
}
URIDecode(str){
	;by Titam
	Loop{
		If(RegExMatch(str,"i)(?<=%)[\da-f]{1,2}",hex))
			StringReplace,str,str,`%%hex%,% Chr("0x" hex),All
		else Break
	}
	Return, str
}