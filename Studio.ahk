class GUIKeep{
	static table:=[]
	__New(win,Studio){
		DetectHiddenWindows,On
		Gui,%win%:+Resize +hwndhwnd
		Gui,%win%:Margin,0,0
		info:=Studio.Style()
		Gui,%win%:Font,% "c" info.color " s" info.size,% info.font
		Gui,%win%:Color,% info.Background,% info.Background
		this.gui:=[],this.hwnd:=hwnd,this.con:=[],this.ahkid:="ahk_id" hwnd,this.win:=win,this.Table[win]:=this,this.var:=[]
		for a,b in {border:33,caption:4}
			this[a]:=DllCall("GetSystemMetrics",int,b)
		Gui,%win%:+LabelGUIKeep.
		Gui,%win%:Default
	}
	Escape(){
		if(IsLabel(A_Gui "Escape")){
			SetTimer,% A_Gui "Escape",-100
			return
		}else
			GUIKeep.table[A_Gui].exit()
		ExitApp
	}
	Exit(){
		if(!top:=settings.ssn("//gui/position[@window='" this.win "']"))
			top:=settings.add("gui/position",,,1),top.SetAttribute("window",this.win),top.text:=this.winpos().text
		for a,b in this.add()
			node.SetAttribute(a,b)
	}
	Size(){
		this:=GUIKeep.table[A_Gui],pos:=this.winpos()
		for a,b in this.gui
			for c,d in b
				GuiControl,% this.win ":MoveDraw",%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}
	Close(){
		if(IsLabel(A_Gui "Close")){
			SetTimer,% A_Gui "Close",-100
			return
		}else
			GUIKeep.table[A_Gui].exit()
		ExitApp
	}
	Show(name){
		this.getpos()
		Gui,% this.win ":Show",% settings.ssn("//gui/position[@window='" this.win "']").text,%name%
		this.size()
	}
	__Get(){
		return this.add()
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
			i:=StrSplit(b,",")
			Gui,% this.win ":Add",% i.1,% i.2 " hwndhwnd",% i.3
			this.con[hwnd]:=[],this.con[hwnd,"pos"]:=i.4
			if(RegExMatch(i.2,"U)\bv(.*)\b",var))
				this.var[var1]:=1
		}
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