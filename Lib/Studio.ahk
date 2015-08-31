global settings
class GUIKeep{
	static table:=[],showlist:=[]
	__New(win,parent:=""){
		#NoTrayIcon
		x:=ComObjActive("AHK-Studio"),path:=x.path(),info:=x.style(),settings:=x.get("settings")
		owner:=winexist("ahk_id" parent)?parent:x.hwnd(1)
		DetectHiddenWindows,On
		if(FileExist(path "\AHKStudio.ico"))
			Menu,Tray,Icon,%path%\AHKStudio.ico
		Gui,%win%:Destroy
		Gui,%win%:+owner%owner% +hwndhwnd
		Gui,%win%:+ToolWindow
		Gui,%win%:Margin,0,0
		Gui,%win%:Font,% "c" info.color " s" info.size,% info.font
		Gui,%win%:Color,% info.Background,% info.Background
		this.x:=studio,this.gui:=[],this.sc:=[],this.hwnd:=hwnd,this.con:=[],this.ahkid:=this.id:="ahk_id" hwnd,this.win:=win,this.Table[win]:=this,this.var:=[]
		for a,b in {border:A_OSVersion~="^10"?3:DllCall("GetSystemMetrics",int,33),caption:DllCall("GetSystemMetrics",int,4)}
			this[a]:=b
		Gui,%win%:+LabelGUIKeep.
		Gui,%win%:Default
	}
	Add(info*){
		static
		if(!info.1){
			var:=[]
			Gui,% this.win ":Submit",Nohide
			for a in this.var
				var[a]:=%a%
			return var
		}
		for a,b in info{
			i:=StrSplit(b,","),newpos:=""
			if(i.1="s"){
				for a,b in StrSplit("xywh")
					RegExMatch(i.2,"i)\b" b "(\S*)\b",found),newpos.=found1!=""?b found1 " ":""
				sc:=new sciclass(this.win,{pos:Trim(newpos)}),this.sc.push(sc)
				hwnd:=sc.sc
			}else{
				Gui,% this.win ":Add",% i.1,% i.2 " hwndhwnd",% i.3
				if(RegExMatch(i.2,"U)\bv(.*)\b",var))
					this.var[var1]:=1
			}
			this.con[hwnd]:=[]
			if(i.4!="")
				this.con[hwnd,"pos"]:=i.4,this.resize:=1
		}
	}
	Escape(){
		KeyWait,Escape,U
		if(IsFunc(escfunc:=A_Gui "Escape"))
			return %escfunc%()
		else
			GUIKeep.table[A_Gui].exit()
	}
	Exit(){
		if(!top:=settings.ssn("//gui/position[@window='" this.win "']"))
			top:=settings.add("gui/position",,,1),top.SetAttribute("window",this.win)
		top.text:=this.winpos().text
		if(exitfunc:=IsFunc(A_Gui "exit")?A_Gui "exit":IsFunc(A_Gui "close")?A_Gui "close":"")
			return %exitfunc%()
		else{
			for a,b in this.add()
				node.SetAttribute(a,b)
			ExitApp
		}
	}
	Close(){
		GUIKeep.table[A_Gui].exit()
	}
	Size(){
		this:=GUIKeep.table[A_Gui],pos:=this.winpos()
		for a,b in this.gui
			for c,d in b
				GuiControl,% this.win ":MoveDraw",%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}
	Show(name){
		this.getpos(),pos:=this.resize=1?"":"AutoSize"
		if(this.resize=1)
			Gui,% this.win ":+Resize"
		GUIKeep.showlist.push(this)
		SetTimer,guikeepshow,-100
		return
		GUIKeepShow:
		while,this:=GUIKeep.Showlist.pop(){
			Gui,% this.win ":Show",% settings.ssn("//gui/position[@window='" this.win "']").text " " pos,%name%
			this.size()
			WinActivate,% this.id
		}
		return
	}
	__Get(){
		return this.add()
	}
	GetPos(){
		Gui,% this.win ":Show",AutoSize Hide
		WinGet,cl,ControlListHWND,% this.ahkid
		pos:=this.winpos(),ww:=pos.w,wh:=pos.h,flip:={x:"ww",y:"wh"}
		for index,hwnd in StrSplit(cl,"`n"){
			obj:=this.gui[hwnd]:=[]
			ControlGetPos,x,y,w,h,,ahk_id%hwnd%
			for c,d in StrSplit(this.con[hwnd].pos)
				d~="w|h"?(obj[d]:=%d%-w%d%):d~="x|y"?(obj[d]:=%d%-(d="y"?wh+this.Caption+this.Border:ww+this.Border))
		}
		Gui,% this.win ":+MinSize"
	}
	WinPos(){
		VarSetCapacity(rect,16),DllCall("GetClientRect",ptr,this.hwnd,ptr,&rect)
		WinGetPos,x,y,,,% this.ahkid
		w:=NumGet(rect,8),h:=NumGet(rect,12),text:=(x!=""&&y!=""&&w!=""&&h!="")?"x" x " y" y " w" w " h" h:""
		return {x:x,y:y,w:w,h:h,text:text}
	}
}
ssn(node,path){
	return node.SelectSingleNode(path)
}sn(node,path){
	return node.SelectNodes(path)
}
m(x*){
	for a,b in x
		msg.=b "`n"
	MsgBox,0,AHK Studio,%msg%
}
t(x*){
	for a,b in x
		msg.=b "`n"
	Tooltip,%msg%
}
Class sciclass{
	static ctrl:=[],main:=[],temp:=[]
	__New(window,info){
		x:=ComObjActive("AHK-Studio")
		static int,count:=1
		if !init
			DllCall("LoadLibrary","str",x.path() "\scilexer.dll"),init:=1
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
		return this
	}
	__Get(x*){
		return DllCall(this.fn,"Ptr",this.ptr,"UInt",x.1,int,0,int,0,"Cdecl")
	}
	__Call(code,lparam=0,wparam=0,extra=""){
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
ea(node){
	ea:=[],all:=node.SelectNodes("@*")
	while,aa:=all.item[A_Index-1]
		ea[aa.NodeName]:=aa.text
	return ea
}