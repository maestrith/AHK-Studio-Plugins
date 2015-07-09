;Menu Paste To p.ahkscript.org
;Menu Paste Clipboard,Clipboard
#NoTrayIcon
#SingleInstance,Force
x:=ComObjActive("AHK-Studio"),x.autoclose(A_ScriptHwnd)
info=%1%
settings:=x.get("settings"),ea:=settings.ea("//GeekDude")
if(info="Clipboard"){
	Clipboard:=MePaste(Clipboard,ea.name,"",""),x.TrayTip(Clipboard " has been copied to your clipboard.")
	ExitApp
}
info:=x.style()
Gui,Font,% "c" info.color,% info.font
Gui,Color,% info.Background,% info.Background
Gui,Add,Edit,vuser w200,% ea.user?ea.user:username
Gui,Add,DDL,vchannel hwndddl,ahk|ahkscript
Gui,Add,Checkbox,vannounce,Announce
Gui,Add,Button,ggeekpost Default,Post
Gui,Add,Button,x+5 gshowcur,Post Current Segment
Gui,Show,,GeekDude Paste
GuiControl,ChooseString,%ddl%,% ea.channel
GuiControl,,announce,% ea.announce
return
GuiEscape:
GuiClose:
Gui,Submit,Nohide
settings:=x.get("settings")
settings.Add({path:"GeekDude",att:{user:user,channel:channel,announce:announce},list:"user,channel,announce"})
ExitApp
return
geekpost:
variable:=newwin[],Clipboard:=mepaste(x.publish(1),variable.user,variable.announce,variable.channel)
TrayTip,Code Posted,%Clipboard% has been copied to your Clipboard,2
x.TrayTip(Clipboard " Has been added to your Clipboard")
ExitApp
return
showcur:
sc:=x.sc()
text:=sc.2008=sc.2009?sc.gettext():x.sc().getseltext()
variable:=newwin[],Clipboard:=mepaste(text,variable.user,variable.announce,variable.channel)
x.TrayTip(Clipboard " Has been added to your Clipboard")
ExitApp
return
post_scratch_pad(){
	postscratchpad:
	sc:=x.sc()
	text:=sc.2008=sc.2009?sc.gettext():x.sc().getseltext(),variable:=newwin[],Clipboard:=mepaste(text,variable.user,variable.announce,variable.channel)
	TrayTip,Code Posted,%Clipboard% has been copied to your Clipboard,2
	return
}
MePaste(Content,Name:="",Announce:=0,channel:="ahkscript"){
	static URL:="http://p.ahkscript.org/"
	Post:="code=" UriEncode(Content),Post.=name?"&name=" UriEncode(Name):"",Post.=announce?"&announce=true":"",Post.="&channel=#" channel
	Pbin:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),Pbin.Open("POST", URL, False),Pbin.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded"),Pbin.Send(POST)
	if pbin.Status()!=200
		return x.m("Something happened")
	return Pbin.Option(1)
}
UriEncode(Uri, RE="[0-9A-Za-z]"){
	VarSetCapacity(Var,StrPut(Uri,"UTF-8"),0),StrPut(Uri,&Var,"UTF-8")
	While Code:=NumGet(Var,A_Index-1,"UChar")
		Res.=(Chr:=Chr(Code))~=RE?Chr:Format("%{:02X}",Code)
	Return,Res
}