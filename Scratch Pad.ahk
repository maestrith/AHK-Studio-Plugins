;menu Scratch Pad
#SingleInstance,Force
global sc,vp,v,commands,hwnd,settings
dir:="lib\Scratch Pad"
if(!FileExist(dir))
	FileCreateDir,%dir%
Gui,+Resize +hwndhwnd
Gui,Margin,0,0
sc:=new s(1,{pos:"w500 h300"}),x:=ComObjActive("AHK-Studio"),v:=x.get("v"),x.color(sc),vp:=[],vp.keywords:=[],commands:=x.get("commands"),settings:=x.get("settings")
info:=x.Style()
Gui,Font,% "c" info.color " s" info.size,% info.font
Gui,Color,% info.Background,% info.Background
for a,b in ["Button,grun,&Run","Button,x+0 gdyna,&Dyna Run","Button,x+0 gkill,&Kill","Button,x+0 gclose,C&lose","Button,x+0 ginsert,&Insert Into Code","Button,x+0 gsppost,&Post"]{
	i:=StrSplit(b,",")
	Gui,Add,% i.1,% i.2,% i.3
}
Gui,Show,Hide,Scratch Pad
for a,b in StrSplit("abcdefghijklmnopqrstuvwxyz")
	vp.keywords[b]:=v.keywords[b]
pos:=settings.ssn("//Scratch_Pad").text,pos:=pos?pos:"w500 h500"
Sleep,10
Gui,Show,%pos%
FileRead,text,%dir%\Scratch Pad.ahk
sc.2181(0,[text])
return
kill:
process.terminate()
return
sppost:
if(!text:=sc.gettext())
	return
SplashTextOn,200,50,Posting to http://p.ahkscript.org,Please Wait...
Clipboard:=paste(text)
SplashTextOff
m(Clipboard " has been coppied to your Clipboard")
return
GuiSize:
ControlGetPos,,,,h,Button1,ahk_id%hwnd%
GuiControl,MoveDraw,Scintilla1,% "w" A_GuiWidth " h" A_GuiHeight-h
Loop,6
	GuiControl,MoveDraw,Button%A_Index%,% "y" A_GuiHeight-h
return
Paste(Content,Name:="",Announce:=0,channel:="ahkscript"){
	static URL:="http://p.ahkscript.org/"
	Post:="code=" UriEncode(Content),Post.=name?"&name=" UriEncode(Name):"",Post.=announce?"&announce=on":"",Post.="&channel=#" channel,Pbin:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),Pbin.Open("POST", URL, False),Pbin.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded"),Pbin.Send(POST)
	if(pbin.Status()!=200)
		return m("Something happened")
	return Pbin.Option(1)
}
UriEncode(Uri,RE="[0-9A-Za-z]"){
	VarSetCapacity(Var,StrPut(Uri,"UTF-8"),0),StrPut(Uri,&Var,"UTF-8")
	While Code:=NumGet(Var,A_Index-1,"UChar")
		Res.=(Chr:=Chr(Code))~=RE?Chr:Format("%{:02X}",Code)
	Return,Res
}
Insert:
msc:=x.sc(),msc.2003(msc.2008,[sc.gettext()])
return
Run:
file:=FileOpen(dir "\Scratch Pad Temp.ahk","rw","utf-8"),file.seek(0),file.write(sc.gettext()),file.length(file.position)
Run,%dir%\scratch pad temp.ahk
return
Dyna:
Process:=x.DynaRun(sc.gettext())
return
GuiClose:
Close:
if(process.processid)
	process.terminate()
pos:=winpos()
settings.add("Scratch_Pad",,pos.text)
file:=FileOpen(dir "\Scratch Pad.ahk","rw","utf-8"),file.seek(0),file.write(sc.gettext()),file.length(file.position)
ExitApp
return
Context(){
	static lastkeyword,syntax
	if(sc.2102)
		return
	cp:=sc.2008,kw:=v.kw,add:=0,pos:=cp-1,start:=sc.2128(line:=sc.2166(cp)),cc:=content:=sc.textrange(start,pos+1),RegExMatch(content,"(#?\w+)",word),pos:=1
	keyword:=v.kw[word1]
	if(!keyword)
		return
	if(keyword!=lastkeyword)
		syntax:=keyword commands.ssn("//Commands/Commands/commands[text()='" keyword "']/@syntax").text
	if(!syntax)
		return
	string:=sc.getline(line),lastkeyword:=keyword
	RegExReplace(RegExReplace(syntax,"\(",","),",","",count),syntax:=RegExReplace(syntax,Chr(96) "n","`n"),RegExReplace(RegExReplace(string,"\(",",","",1),",","",current)
	if(!count)
		return sc.2207(0xff0000),syn:=start?start syntax:syntax,sc.2200(startpos:=sc.2128(sc.2166(sc.2008)),syn),RegExMatch(syn,"O)^.*?(\w).*(\w).*?$",pos),sc.2204(pos.Pos(1)-1,pos.Pos(2))
	else{
		ff:=RegExReplace(syntax,"\(",","),sc.2207(0xff0000),sc.2200(startpos:=sc.2128(sc.2166(sc.2008)),syntax)
		if(current+1<=count)
			sc.2204(InStr(ff,",",0,1,current),InStr(ff,",",0,1,current+1)-1)
		if(current=count)
			end:=RegExMatch(syntax,"(\n|\]|\))"),end:=end?end-1:strlen(ff),sc.2204(InStr(ff,",",0,1,current),end)
		if(current>count)
			sc.2204(0,StrLen(ff)),sc.2207(0x0000ff)
	}
	return
}
Notify(){
	fn:=[],info:=A_EventInfo,code:=NumGet(info+(A_PtrSize*2))
	if code not in 2001,2002,2004,2006,2007,2008,2010,2014,2018,2019,2021,2022,2027
		return 0
	for a,b in {0:"Obj",3:"position",4:"ch",5:"mod",6:"modType",7:"text",8:"length",9:"linesadded",10:"msg",11:"wparam",12:"lparam",13:"line",14:"fold",17:"listType",22:"updated"}
		fn[b]:=NumGet(Info+(A_PtrSize*a))
	cpos:=sc.2008,start:=sc.2266(cpos,1),end:=sc.2267(cpos,1),word:=sc.getword()
	if(code=2001){
		if((StrLen(word)>1&&sc.2102=0&&v.options.Disable_Auto_Complete!=1)){
			word:=RegExReplace(word,"^\d*"),list:=Trim(vp.keywords[SubStr(word,1,1)])
			if(!sc.2202&&v.options.Disable_Auto_Complete_While_Tips_Are_Visible=1){
			}else{
				if(list&&InStr(list,word))
					sc.2100(StrLen(word),list)
			}
		}
		context()
	}
}
class s{
	static ctrl:=[],main:=[],temp:=[]
	__New(window,info){
		static int,count:=1
		if !init
			DllCall("LoadLibrary","str","..\scilexer.dll"),init:=1
		win:=window?window:1,pos:=info.pos?info.pos:"x0 y0"
		if info.hide
			pos.=" Hide"
		notify:=info.label?info.label:"notify"
		Gui,%win%:Add,custom,classScintilla hwndsc w500 h400 %pos% +1387331584 g%notify%
		this.sc:=sc,t:=[],s.ctrl[sc]:=this
		for a,b in {fn:2184,ptr:2185}
			this[a]:=DllCall("SendMessageA","UInt",sc,"int",b,int,0,int,0)
		v.focus:=sc,this.2660(1)
		for a,b in [[2563,1],[2565,1],[2614,1],[2402,15,75],[2124,1]]{
			b.2:=b.2?b.2:0,b.3:=b.3?b.3:0
			this[b.1](b.2,b.3)
		}
		if info.main
			s.main.Insert(this)
		if info.temp
			s.temp.Insert(this)
		this.2052(32,0),this.2051(32,0xaaaaaa),this.2050,this.2052(33,0x222222),this.2069(0xAAAAAA),this.2601(0xaa88aa),this.2563(1),this.2614(1),this.2565(1),this.2660(1)
		this.2036(width:=settings.ssn("//tab").text?settings.ssn("//tab").text:5),this.2124(1),this.2260(1),this.2122(5)
		this.2277(0),this.2056(38,"Consolas"),this.2516(1)
		return this
	}
	__Get(x*){
		return DllCall(this.fn,"Ptr",this.ptr,"UInt",x.1,int,0,int,0,"Cdecl")
	}
	__Call(code,lparam=0,wparam=0,extra=""){
		if(code="getword"){
			cpos:=lparam?lparam:sc.2008
			return sc.textrange(sc.2266(cpos,1),sc.2267(cpos,1))
		}
		if(code="getseltext"){
			VarSetCapacity(text,this.2161),length:=this.2161(0,&text)
			return StrGet(&text,length,"UTF-8")
		}
		if(code="textrange"){
			cap:=VarSetCapacity(text,abs(lparam-wparam)),VarSetCapacity(textrange,12,0),NumPut(lparam,textrange,0),NumPut(wparam,textrange,4),NumPut(&text,textrange,8)
			this.2162(0,&textrange)
			return strget(&text,cap,"UTF-8")
		}
		if(code="getline"){
			length:=this.2350(lparam),cap:=VarSetCapacity(text,length,0),this.2153(lparam,&text)
			return StrGet(&text,length,"UTF-8")
		}
		if(code="gettext"){
			cap:=VarSetCapacity(text,vv:=this.2182),this.2182(vv,&text),t:=strget(&text,vv,"UTF-8")
			return t
		}
		if(code="getuni"){
			cap:=VarSetCapacity(text,vv:=this.2182),this.2182(vv,&text),t:=StrGet(&text,vv,"UTF-8")
			return t
		}
		wp:=(wparam+0)!=""?"Int":"AStr",lp:=(lparam+0)!=""?"Int":"AStr"
		if(wparam.1)
			wp:="AStr",wparam:=wparam.1
		wparam:=wparam=""?0:wparam,lparam:=lparam=""?0:lparam
		info:=DllCall(this.fn,"Ptr",this.ptr,"UInt",code,lp,lparam,wp,wparam,"Cdecl")
		return info
	}
	show(){
		GuiControl,+Show,% this.sc
	}
}
m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,,AHK Studio,% list
}
t(x*){
	for a,b in x
		list.=b "`n"
	ToolTip,% list
}
WinPos(){
	VarSetCapacity(rect,16),DllCall("GetClientRect",ptr,hwnd,ptr,&rect)
	WinGetPos,x,y,,,ahk_id%hwnd%
	w:=NumGet(rect,8),h:=NumGet(rect,12),text:=(x!=""&&y!=""&&w!=""&&h!="")?"x" x " y" y " w" w " h" h:""
	return {x:x,y:y,w:w,h:h,text:text}
}