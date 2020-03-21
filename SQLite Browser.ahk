#SingleInstance,Force
;menu DB Browser
global DB:=New MySQL(),MainWin,Words,OWords:="ALTER,COUNT(),CREATE,DROP,EXISTS,FROM,IF,LIKE,LIMIT,NOT,OID,PRAGMA,RowID,SELECT,SET,TABLE,table_info,UPDATE,WHERE,WITH",History:=[],HistoryWin
x:=Studio()
x:=ComObjActive("AHK-Studio")
File:=x.Current(2).File
SplitPath,File,,Folder
Files:=[]
SetBatchLines,-1
Loop,Files,%Folder%\*.DB
	Files.Push([A_LoopFileLongPath])
if(Files.Count()>1){
	SmallWin:=New GUIClass(2,{Background:0,Color:"0xAAAAAA"})
	SmallWin.Add("ListView,w500 h300 vFile NoSortHdr,Foo,wh"
			  ,"Button,gOpen Default,Open")
	SmallWin.SetLV({Data:Files,Headers:["Files"]})
	LV_Modify(1,"Select Vis Focus")
	SmallWin.Show("Choose File")
}else
	ShowBrowser(Files.1.1)
return
ShowBrowser(File){
	global
	DB.Open(File)
	MainWin:=New GUIClass(1,{Background:0,Color:"0xAAAAAA"})
	/*
		DB.Exec("CREATE TABLE IF NOT EXISTS " DB.ORNull("Peo" Chr(34) "ple")"(a,b,UNIQUE(a) ON CONFLICT IGNORE)",A_ThisFunc,A_LineNumber)
		DB.Exec("INSERT INTO " DB.ORNull("Peo" Chr(34) "ple")" VALUES(1,2)",A_ThisFunc "`n" A_LineNumber)
		m(DB.Exec(Foo:="SELECT * FROM " DB.ORNull("Peo" Chr(34) "ple") " WHERE " DB.ORNull("Property_Permalink") " IS NOT NULL LIMIT 2",A_LineNumber),Foo)
	*/
	MainWin.Add("Text,,&Table:"
			 ,"ListView,vTables gTables w200 h200 AltSubmit -Multi,TABLE"
			 ,"Text,x+m ym,&Columns:"
			 ,"ListView,vColumns w200 h200 gColumns Checked AltSubmit,Columns"
			 ,"Text,xm,&Limit:"
			 ,"Edit,w200 vLimit Number gUpdateLimit,20"
			 ,"Radio,xm vNoAction gNoAction Checked,&No Action"
			 ,"Radio,vUpdate,&Update"
			 ,"Radio,vDelete gDelete,&Delete"
			 ,"Checkbox,vCount gShowSQL,C&ount"
			 ,"Text,,S&QL String: (F1 For History)"
			 ,"S,w500 h22 vs,,w"
			 ,"Text,,&Results:"
			 ,"ListView,w500 vResults gResults AltSubmit,Results,wh")
	MainWin.Show("DB Browser")
	MainWin.Hotkeys({Escape:"1Escape",Enter:"Enter","~*LButton":"LButton",F1:"History"})
	sc:=MainWin.SC.S
	SC.2130(0)
	SC.2242(1,0)
	for a,b in {2051:[32,"11184810"],2052:[32,"0"]}
		SC[a](b.1,b.2)
	SC.2050
	SC.2069(0xAAAAAA)
	SC.2115(1)
	PopulateTables()
	SetWords()
}
History(){
	HistoryWin:=New GUIClass("History_Window",{Background:0,Color:"0xAAAAAA"})
	HistoryWin.Add("ListView,w500 h200 vHist,SQL Query,wh"
			    ,"Button,gPopulateHistory Default,Insert")
	HistoryWin.Show("History Window")
	HistoryWin.Default("Hist")
	HH:=[]
	for a,b in History
		HH.Push([a])
	HistoryWin.SetLV({Data:HH})
	return
	PopulateHistory:
	HH:=HistoryWin[].Hist
	MainWin.SetText("S",HH[HH.MinIndex()].1)
	return
}
History_WindowEscape(){
	HistoryWin.Close()
}
NoAction(){
	ShowSQL()
}
Results(a,b,c){
	if(b="I"){
		if(MainWin[].Delete)
			Delete()
	}
}
LButton(){
	SetTimer,LButtonGo,-100
	LButtonGo:
	MouseGetPos,,,Win,Ctrl,2
	if(MainWin.GetName(Ctrl)="Results"){
		Obj:=MainWin[],Table:=Obj.Tables[Obj.Tables.MinIndex()].1
		MainWin.Default("Results"),Next:=LV_GetNext()
		if(Obj.Update&&Next){
			Item:=LV_SubitemHitTest(Ctrl)
			LV_GetText(Text,Next,Item)
			Obj:=MainWin.LookUp.Results
			MainWin.SetText("S","UPDATE " Chr(34) DB.Clean(Table) Chr(34) " SET " Chr(34) DB.Clean(DB.OO.Col[Item]) Chr(34) "='" DB.Clean(Text) "' WHERE OID=" Next)
		}
	}
	return
}
Delete(){
	for a,b in (Obj:=MainWin[]).Results{
		List.=b.1 ","
	}List:=Trim(List,","),Table:=Obj.Tables,Table:=Table[Table.MinIndex()].1
	if(List)
		MainWin.SetText("S","DELETE FROM '" DB.Clean(Table) "' WHERE OID IN (" List ")")
}
Columns(a,b,c){
	if(b="C"||c="32"){
		ShowSQL()
	}
}
UpdateLimit(){
	Obj:=MainWin[]
	MainWin.SetText("S",RegExReplace(Obj.S,"i)Limit (\d+)?","Limit " Obj.Limit))
}
ShowSQL(){
	MainWin.Default("Columns"),Count:=0
	while(Next:=LV_GetNext(Next,"C"))
		LV_GetText(Text,Next),List.=(Text~="(\S|')"?Chr(34) DB.Clean(Text) Chr(34):Text) ",",Count++
	if(Count=LV_GetCount())
		SQL:="SELECT OID,* FROM "
	else
		SQL:="SELECT " Trim(List,",") " FROM "
	Obj:=MainWin[]
	if(Obj.Count)
		SQL:=RegExReplace(SQL,"i)(SELECT\s+)","SELECT COUNT(),")
	Table:=Obj.Tables
	Table:=Table[Table.MinIndex()].1
	SQL.=DB.ORNull(Table) (Obj.Limit?" Limit " Obj.Limit:"")
	MainWin.SetText("S",SQL)
}
Tables(a,b,c){
	global
	if(b="i"){
		Table:=MainWin[].Tables
		Table:=Table[Table.MinIndex()].1,Columns:=[["RowID"]],Extra:=""
		for a,b in MainWin.StoredLV.Tables
			Extra.="," b.1
		for a,b in DB.Exec("PRAGMA table_info('" DB.Clean(Table) "')",A_ThisFunc "`n" A_LineNumber)
			Columns.Push([b.Name]),Extra.="," b.Name
		MainWin.SetLV({Control:"Columns",Data:Columns,Clear:1})
		Loop,% LV_GetCount()
			LV_Modify(A_Index,"Check")
		LV_Modify(1,"Select Vis Focus"),ShowSQL(),SetWords(Extra)
	}
}
PopulateTables(){
	global
	type=Table
	Tables:=[]
	for a,b in DB.Exec("SELECT Name FROM sqlite_master WHERE type='table'")
		Tables.Push([b.Name])
	MainWin.SetLV({Control:"Tables",Data:Tables,Headers:["Table"]})
	LV_ModifyCol(1,"Sort"),LV_Modify(1,"Select Vis Focus")
}
Open(){
	global
	File:=SmallWin[].File
	ShowBrowser(File[File.MinIndex()].1)
	SmallWin.SavePos(),SmallWin.Close()
}
2Escape(){
	ExitApp
}
1Escape(){
	global
	MainWin.Exit()
}
Enter(){
	global
	sc:=MainWin.SC.S
	if(SC.2102)
		Send,{Enter}
	else{
		Obj:=DB.Exec((SQL:=SC.GetUni()),A_LineNumber),History[SQL]:=1
		MainWin.DisableAll(0)
		MainWin.DisableAll(1,"Results")
		MainWin.SetLV({Control:"Results",Data:Obj,Headers:DB.OO.Col,Clear:1,AutoHDR:1})
		MainWin.EnableAll(0)
		MainWin.EnableAll(1,"Results")
	}
}
SetWords(Extra:=""){
	Words:=OWords Extra
	Sort,Words,d`,
	Words:=StrSplit(Words,",")
}
Notify(){
	global Words
	static Values:={0:"Obj",2:"Code",3:"Position",4:"CH",5:"Mod",6:"ModType",7:"Text",8:"Length",9:"LinesAdded",10:"Msg",11:"WParam",12:"LParam",13:"Line",14:"Fold",15:"PrevFold",17:"ListType",22:"Updated",23:"Method"}
	static CodeGet:={2001:{CH:4},2005:{CH:4,Mod:5},2006:{Position:3,Mod:5},2007:{Updated:22},2008:{Position:3,ModType:6,Text:7,Length:8,LinesAdded:9,Line:13,Fold:14,PrevFold:15},2010:{Position:3,Margin:16},2011:{Position:3},2014:{Position:3,CH:4,Text:7,ListType:17,Method:23},2016:{x:18,y:19},2019:{Position:3,Mod:5},2021:{Position:3},2022:{Position:3,CH:4,Text:7,Method:23},2027:{Position:3,Mod:5}}
	static Hold:=[],Insert:={(Chr(34)):Chr(34),"'":"'","<":">","(":")"}
	FN:=[],Info:=A_EventInfo,Code:=NumGet(Info+8)
	if(!Code)
		return 0
	if Code not in 2007,2001,2006,2008,2010,2014,2022,2016,2019
		return 0
	FN:=[],FN.Code:=Code,FN.CTRL:=NumGet(A_EventInfo+0),sc:=S.Ctrl[FN.Ctrl]
	for a,b in CodeGet[Code]{
		if(a="Text")
			FN.Text:=StrGet(NumGet(Info+(A_PtrSize*b)),FN.Length,"UTF-8")
		else
			FN[a]:=NumGet(Info+(A_PtrSize*b))
	}
	if(Code=2001){
		Word:=SC.GetWord()
		if(StrLen(Word)){
			for a,b in Words{
				if(SubStr(b,1,StrLen(Word))=Word){
					List.=b " "
				}
			}
			List:=Trim(List)
			SC.2100(StrLen(Word),List)
		}
	}else if(Code=2008){
		if((Ins:=Insert[FN.Text])&&FN.ModType!=8210){
			Hold:={SC:SC,Ins:Ins}
			SetTimer,AddClose,-10
			return
			AddClose:
			sc:=Hold.SC
			SC.Enable(0)
			SC.2003(SC.2008,Hold.Ins)
			SC.Enable(1)
			return
		}
		
	}
}
Class S{
	static CTRL:=[],Main:=[],Temp:=[],Hidden:=[]
	__New(Window,Info){
		static Int,Count:=1
		if(Window=1)
			if(sc:=S.Hidden.Pop()){
				sc:=S.Ctrl[SC],SC.Hidden:=0
				return SC
			}
		if(!FileExist(FN:=A_ScriptDir "\SciLexer.dll"))
			URLDownloadToFile,https://github.com/maestrith/AHK-Studio/blob/master/SciLexer.dll?raw=true,%FN%
		if(!Init)
			DllCall("LoadLibrary",Str,FN),Init:=1
		if(Info.Hide)
			Pos.=" Hide"
		Mask:=0x10000000|0x400000|0x40000000,Notify:=Info.Notify?Info.Notify:"Notify"
		Win:=Window?Window:1,Pos:=Info.Pos?Info.Pos:"x0 y0 w0 h0",this.Win:=Window,this.Notify:=Notify
		Gui,%Win%:Add,Custom,% Pos " ClassScintilla +" Mask " HWNDsc " (IsFunc(Notify)?"g" Notify:"") ;g%Notify% ; +1387331584
		for a,b in {FN:2184,ptr:2185}
			this[a]:=DllCall("SendMessageA",UInt,SC,Int,b,Int,0,Int,0)
		this.Parent:=SC,this.sc:=SC+0
		if(!Info.Notify)
			S.Ctrl[SC]:=this
		if(Info.Center_Caret)
			this.2402(4|8,0),this.2403(4|8,0)
		if(Info.Main)
			S.Main.Push(this)
		if(Info.Temp)
			S.Temp.Push(this)
		return this
	}__Get(x*){
		return DllCall(this.FN,ptr,this.ptr,UInt,x.1,Int,0,Int,0,"Cdecl")
	}__Call(Code,LParam=0,WParam=0,Extra=""){
		static Text
		if(Code=2181){
			this.Enable(0),Len:=VarSetCapacity(Text,(StrPut(WParam,Encoding)*((Encoding="UTF-16"||Encoding="cp1200")?2:1))),StrPut(WParam,&Text,Len,"UTF-8"),RR:=DllCall(this.FN,Ptr,this.Ptr,UInt,Code,Int,0,UPtr,&Text,"CDECL"),this.Enable(1)
			return RR
		}if(Code="Enable"){
			if(LParam){
				GuiControl,% this.Win ":+Redraw",% this.SC
				GuiControl,% this.Win ":+g" this.Notify,% this.SC
			}else{
				GuiControl,% this.Win ":-Redraw",% this.SC
				GuiControl,% this.Win ":+g",% this.SC
		}}if(Code="GetWord"){
			return this.TextRange(this.2266((CPos:=this.2008),1),this.2267(CPos,1))
		}else if(Code="GetSelText"){
			VarSetCapacity(Text,this.2161),Length:=this.2161(0,&Text)
			return StrGet(&Text,Length,"UTF-8")
		}else if(Code="TextRange"){
			Cap:=VarSetCapacity(Text,Abs(LParam-WParam)),VarSetCapacity(TextRange,12,0),NumPut(LParam,TextRange,0),NumPut(WParam,TextRange,4),NumPut(&Text,TextRange,8),this.2162(0,&TextRange)
			return StrGet(&Text,Cap,"UTF-8")
		}else if(Code="GetLine"&&LParam!=""){
			Length:=this.2350(LParam),Cap:=VarSetCapacity(Text,Length,0),this.2153(LParam,&Text)
			return StrGet(&Text,Length,"UTF-8")
		}else if(Code="GetPlain"){
			Cap:=VarSetCapacity(Text,vv:=this.2182),this.2182(vv,&Text),t:=StrGet(&Text,vv,LParam)
			return t
		}else if(Code="GetText"){
			Cap:=VarSetCapacity(Text,vv:=this.2182),this.2182(vv,&Text),t:=StrGet(&Text,vv,"UTF-8")
			return t
		}else if(Code="GetUni"){
			VarSetCapacity(Text,vv:=this.2182),this.2182(vv,&Text)
			return StrGet(&Text,vv,"UTF-8")
		}else if(Code="ET"){
			Len:=VarSetCapacity(Text,(StrPut(TT,Encoding)*((Encoding="UTF-16"||Encoding="cp1200")?2:1))),StrPut(TT,&Text,Len,"UTF-8")
			return &Text
		}wp:=(WParam+0)!=""?"Int":"AStr",lp:=(LParam+0)!=""?"Int":"AStr"
		if(WParam.1!="")
			wp:="UInt",WParam:=this.ET(WParam.1)
		WParam:=WParam=""?0:WParam,LParam:=LParam=""?0:LParam
		if(WParam=""||LParam="")
			return
		return DllCall(this.FN,ptr,this.ptr,UInt,Code,lp,LParam,wp,WParam,"Cdecl")
	}
}
LV_SubitemHitTest(HLV){ ;https://autohotkey.com/board/topic/80265-solved-which-column-is-clicked-in-listview/ Just Me
	VarSetCapacity(Point,8,0),DllCall("User32.dll\GetCursorPos",ptr,&Point),DllCall("User32.dll\ScreenToClient",ptr,HLV,ptr,&Point),VarSetCapacity(Info,24,0),NumPut(NumGet(Point,0,Int),Info,0,Int),NumPut(NumGet(Point,4,Int),Info,4,Int)
	SendMessage,0x1039,0,&Info,,ahk_id %HLV% ;LVM_SUBITEMHITTEST
	if(ErrorLevel=-1)
		return 0
	Subitem:=NumGet(Info,16,Int)+1
	return Subitem
}
global settings
Studio(ico:=0){
	global x
	if(ico)
		Menu,Tray,Icon
	Try
		x:=ComObjActive("AHK-Studio")
	Catch m
		x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
	return x,x.autoclose(A_ScriptHwnd)
}
class GUIKeep{
	static table:=[],showlist:=[]
	__New(win,parent:=""){
		#NoTrayIcon
		Try
			x:=ComObjActive("AHK-Studio")
		Catch m
			x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
		path:=x.path(),info:=x.style(),settings:=x.get("settings")
		owner:=WinExist("ahk_id" parent)?parent:x.hwnd(1)
		DetectHiddenWindows,On
		if(FileExist(path "\AHKStudio.ico"))
			Menu,Tray,Icon,%path%\AHKStudio.ico
		Gui,%win%:Destroy
		Gui,%win%:+owner%owner% +hwndhwnd -DPIScale
		Gui,%win%:+ToolWindow
		if(settings.ssn("//options/@Add_Margins_To_Windows").text!=1)
			Gui,%win%:Margin,0,0
		Gui,%win%:Font,% "c" info.color " s" info.size,% info.font
		Gui,%win%:Color,% info.Background,% info.Background
		this.x:=studio,this.gui:=[],this.sc:=[],this.hwnd:=hwnd,this.con:=[],this.ahkid:=this.id:="ahk_id" hwnd,this.win:=win,this.Table[win]:=this,this.var:=[]
		for a,b in {border:A_OSVersion~="^10"?3:0,caption:DllCall("GetSystemMetrics",int,4,"int")}
			this[a]:=b
		Gui,%win%:+LabelGUIKeep.
		Gui,%win%:Default
	}
	DropFiles(filelist,ctrl,x,y){
		df:="DropFiles"
		if(IsFunc(df))
			%df%(filelist,ctrl,x,y)
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
	}ContextMenu(a,b,c,d){
		if(IsFunc(Function:=A_Gui "GuiContextMenu"))
			%Function%(a,b)
	}
	Escape(){
		this:=GUIKeep.table[A_Gui]
		KeyWait,Escape,U
		if(IsFunc(func:=A_Gui "Escape"))
			return %func%()
		else if(IsLabel(label:=A_Gui "Escape"))
			SetTimer,%label%,-1
		else
			this.savepos(),this.exit()
	}
	savepos(){
		if(!top:=settings.ssn("//gui/position[@window='" this.win "']"))
			top:=settings.add("gui/position",,,1),top.SetAttribute("window",this.win)
		top.text:=this.winpos().text
	}
	Exit(){
		global x
		this.savepos(),x.activate()
		ExitApp
	}
	Close(a:=""){
		this:=GUIKeep.table[A_Gui]
		if(IsFunc(func:=A_Gui "Close"))
			return %func%()
		else if(IsLabel(label:=A_Gui "Close"))
			SetTimer,%label%,-1
		else
			this.savepos(),this.exit()
	}
	Size(){
		this:=GUIKeep.table[A_Gui],pos:=this.winpos()
		for a,b in this.gui
			for c,d in b
				GuiControl,% this.win ":MoveDraw",%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}
	Show(name){
		this.getpos(),pos:=this.resize=1?"":"AutoSize",this.name:=name
		if(this.resize=1)
			Gui,% this.win ":+Resize"
		GUIKeep.showlist.push(this)
		SetTimer,guikeepshow,-100
		return
		GUIKeepShow:
		while,this:=GUIKeep.Showlist.pop(){
			Gui,% this.win ":Show",% settings.ssn("//gui/position[@window='" this.win "']").text " " pos,% this.name
			this.size()
			if(this.resize!=1)
				Gui,% this.win ":Show",AutoSize
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
		w:=NumGet(rect,8,"int"),h:=NumGet(rect,12,"int"),text:=(x!=""&&y!=""&&w!=""&&h!="")?"x" x " y" y " w" w " h" h:""
		return {x:x,y:y,w:w,h:h,text:text}
	}
}
/*
	Exit(){
		ExitApp
	}
*/
Class sciclass{
	static ctrl:=[],main:=[],temp:=[]
	__New(window,info){
		Try
			x:=ComObjActive("AHK-Studio")
		Catch m
			x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
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
			this[a]:=DllCall("SendMessageA","UInt",sc,"int",b,int,0,int,0,"int")
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
EA(node){
	ea:=[],all:=node.SelectNodes("@*")
	while,aa:=all.item[A_Index-1]
		ea[aa.NodeName]:=aa.text
	return ea
}
/*
	Class XML{
		keep:=[]
		__New(param*){
			if !FileExist(A_ScriptDir "\lib")
				FileCreateDir,%A_ScriptDir%\lib
			root:=param.1,file:=param.2
			file:=file?file:root ".xml"
			temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath")
			this.xml:=temp
			if FileExist(file){
				FObject:=FileOpen(file,"R","UTF-8"),info:=FObject.Read(FObject.Length),FObject.Close()
				if(info=""){
					this.xml:=this.CreateElement(temp,root)
					FileDelete,%file%
				}else
					temp.loadxml(info),this.xml:=temp
			}else
				this.xml:=this.CreateElement(temp,root)
			this.file:=file
			xml.keep[root]:=this
		}
		CreateElement(doc,root){
			return doc.AppendChild(this.xml.CreateElement(root)).parentnode
		}
		Search(node,find,return=""){
			found:=this.xml.SelectNodes(node "[contains(.,'" RegExReplace(find,"&","')][contains(.,'") "')]")
			while,ff:=found.item(a_index-1)
				if (ff.text=find){
					if return
						return ff.SelectSingleNode("../" return)
					return ff.SelectSingleNode("..")
				}
		}
		Lang(info){
			info:=info=""?"XPath":"XSLPattern"
			this.xml.temp.setProperty("SelectionLanguage",info)
		}
		Add(path,att:="",text:="",dup:=0,list:=""){
			p:="/",dup1:=this.ssn("//" path)?1:0,next:=this.ssn("//" path),last:=SubStr(path,InStr(path,"/",0,0)+1)
			if !next.xml{
				next:=this.ssn("//*")
				Loop,Parse,path,/
					last:=A_LoopField,p.="/" last,next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.CreateElement(last))
			}
			if(dup&&dup1)
				next:=next.parentnode.appendchild(this.xml.CreateElement(last))
			for a,b in att
				next.SetAttribute(a,b)
			for a,b in StrSplit(list,",")
				next.SetAttribute(b,att[b])
			if(text!="")
				next.text:=text
			return next
		}
		Find(info*){
			doc:=info.1.NodeName?info.1:this.xml
			if(info.1.NodeName)
				node:=info.2,find:=info.3
			else
				node:=info.1,find:=info.2
			if InStr(find,"'")
				return doc.SelectSingleNode(node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/..")
			else
				return doc.SelectSingleNode(node "[.='" find "']/..")
		}
		Under(under,node:="",att:="",text:="",list:=""){
			if(node="")
				node:=under.node,att:=under.att,list:=under.list,under:=under.under
			new:=under.appendchild(this.xml.createelement(node))
			for a,b in att
				new.SetAttribute(a,b)
			for a,b in StrSplit(list,",")
				new.SetAttribute(b,att[b])
			if text
				new.text:=text
			return new
		}
		SSN(path){
			return this.xml.SelectSingleNode(path)
		}
		SN(path){
			return this.xml.SelectNodes(path)
		}
		__Get(x=""){
			return this.xml.xml
		}
		Get(path,Default){
			return value:=this.ssn(path).text!=""?this.ssn(path).text:Default
		}
		Transform(){
			static
			if !IsObject(xsl){
				xsl:=ComObjCreate("MSXML2.DOMDocument")
				style=<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">`n<xsl:output method="xml" indent="yes" encoding="UTF-8"/>`n<xsl:template match="@*|node()">`n<xsl:copy>`n<xsl:apply-templates select="@*|node()"/>`n<xsl:for-each select="@*">`n<xsl:text></xsl:text>`n</xsl:for-each>`n</xsl:copy>`n</xsl:template>`n</xsl:stylesheet>
				xsl.loadXML(style),style:=null
			}
			this.xml.transformNodeToObject(xsl,this.xml)
		}
		Save(x*){
			if x.1=1
				this.Transform()
			filename:=this.file?this.file:x.1.1
			if(Trim(this[])="")
				return
			file:=FileOpen(filename,"W","UTF-8"),file.write(this[]),file.length(file.position)
		}
		EA(path){
			list:=[]
			if nodes:=path.nodename
				nodes:=path.SelectNodes("@*")
			else if path.text
				nodes:=this.sn("//*[text()='" path.text "']/@*")
			else if !IsObject(path)
				nodes:=this.sn(path "/@*")
			else
				for a,b in path
					nodes:=this.sn("//*[@" a "='" b "']/@*")
			while,n:=nodes.item(A_Index-1)
				list[n.nodename]:=n.text
			return list
		}
	}
	SSN(node,path){
		return node.SelectSingleNode(path)
	}
	SN(node,path){
		return node.SelectNodes(path)
	}
	ATT(node,info){
		for a,b in info
			node.setattribute(a,b)
	}
*/

Class GUIClass{
	static Table:=[],ShowList:=[]
	__Get(x*){
		if(x.1)
			return this.Var[x.1]
		return this.Add()
	}__New(Win:=1,Info:=""){
		static Defaults:={Color:0,Size:10,MarginX:5,MarginY:5}
		for a,b in Defaults
			if(Info[a]="")
				Info[a]:=b
		SetWinDelay,-1
		Gui,%Win%:Destroy
		Gui,%Win%:+HWNDHWND -DPIScale
		this.MarginX:=Info.MarginX,this.MarginY:=Info.MarginY
		Gui,%Win%:Margin,% this.MarginX,% this.MarginY
		Gui,%Win%:Font,% "s" Info.Size " c" Info.Color,Courier New
		if(Info.Background!="")
			Gui,%Win%:Color,% Info.Background,% Info.Background
		this.All:=[],this.GUI:=[],this.HWND:=HWND,this.Con:=[],this.ID:="ahk_id" HWND,this.Win:=Win,GUIClass.Table[Win]:=this,this.Var:=[],this.LookUp:=[],this.ActiveX:=[],this.StoredLV:=[],this.Background:=Info.Background,this.Color:=Info.Color,this.SC:=[],this.Headers:=[]
		for a,b in {Border:A_OSVersion~="^10"?3:0,Caption:DllCall("GetSystemMetrics",Int,4,Int)}
			this[a]:=b
		Gui,%Win%:+LabelGUIClass.
		Gui,%Win%:Default
		return this
	}Add(Info*){
		static
		if(Info.1=""||Info.1.Get){
			Var:=[],Get:=Info.1.Get!=""?{(Info.1.Get):this.Var[Info.1.Get]}:this.Var
			Gui,% this.Win ":Submit",Nohide
			Try
				for a,b in Get{
					if(b.Type="s")
						Var[a]:=b.sc.GetUNI()
					else if(b.Type="ListView"){
						Var[a]:=[],this.Default(a)
						while(Next:=LV_GetNext(Next)){
							Obj:=Var[a,Next]:=[]
							Loop,% LV_GetCount("Columns")
								LV_GetText(Text,Next,A_Index),Obj.Push(Text)
						}
					}else if(b.Type="TreeView"){
						Var[a]:=[],this.Default(a),TV:=TV_GetSelection()
						while(Next:=TV_GetNext(Next,(this.All[a].Full?"F":"C")))
							Var[a].Push({TV:Next,Checked:(TV_Get(Next,"Checked")?1:0),Expand:(TV_Get(Next,"Expand")?1:0),Bold:(TV_Get(Next,"Bold")?1:0)}),Found:=Found?Found:TV=Next
						if(!Found)
							Var[a].Push({TV:TV,Checked:0,Expand:(TV_Get(TV,"Expand")?1:0),Bold:(TV_Get(TV,"Bold")?1:0)})
					}else
						Var[a]:=%a%
				}return Var,Found:=""
		}for a,b in Info{
			i:=StrSplit(b,","),RegExMatch(i.2,"OU)\bv(.*)\b",Var)
			if(i.1="ComboBox")
				WinGet,ControlList,ControlList,% this.ID
			if(i.1="s")
				Pos:=RegExReplace(i.2,"OU)\s*\b(v.+)\b"),sc:=New S(this.Win,{Pos:Pos}),HWND:=sc.sc,this.SC[Var.1]:=sc
			else
				Gui,% this.Win ":Add",% i.1,% i.2 " HWNDHWND",% i.3
			if(RegExMatch(i.2,"OU)\bg(.*)\b",Label))
				Label:=Label.1
			if(Var.1)
				this.Var[Var.1]:={HWND:HWND,Type:i.1,sc:sc}
			this.Con[HWND]:=[],Name:=Var.1?Var.1:Label,this.Con[HWND,"Name"]:=Name,Name:=Var.1?Var.1:Label?Label:"Control" A_TickCount A_MSec
			if(i.4!="")
				this.Con[HWND,"Pos"]:=i.4,this.Resize:=1
			this.All[Name]:={HWND:HWND,Name:Name,Label:Label,Type:i.1,ID:"ahk_id" HWND,sc:sc},sc:=""
			if(i.1="ComboBox"){
				WinGet,ControlList2,ControlList,% this.ID
				Obj:=StrSplit(ControlList2,"`n"),LeftOver:=[]
				for a,b in Obj
					LeftOver[b]:=1
				for a,b in Obj2:=StrSplit(ControlList,"`n")
					LeftOver.Delete(b)
				for a in LeftOver{
					if(!InStr(a,"ComboBox")){
						ControlGet,Married,HWND,,%a%,% this.ID
						this.LookUp[Name]:={HWND:HWND,Married:Married,ID:"ahk_id" Married+0,Name:Name,Type:"Edit"}
			}}}if(!this.LookUp[Name]&&Name)
				this.LookUp[Name]:={HWND:HWND,ID:"ahk_id" HWND,Name:Name,Label:Label,Type:i.1}
			if(i.1="ActiveX")
				VV:=Var.1,this.ActiveX[Name]:=%VV%
			Name:=""
	}}Close(a:=""){
		this:=GUIClass.Table[A_Gui],(Func:=Func("SavePos"))?Func.Call(this.Win,this.WinPos()):this.SavePos(),(Func:=Func(A_Gui "Close"))?Func.Call():""
		Gui,% this.Win ":Destroy"
		this.DisableAll()
	}ContextMenu(x*){
		this:=GUIClass.Table[A_Gui],x.1:=this.GetName(x.1),(Function:=Func(A_Gui "ContextMenu"))?Function.Call(x*)
	}Default(Control){
		Gui,% this.Win ":Default"
		Obj:=this.LookUp[Control]
		if(Obj.Type~="TreeView|ListView")
			Gui,% this.Win ":" Obj.Type,% Obj.HWND
	}Disable(Control){
		Obj:=this.All[Control]
		if(Obj.Label)
			GuiControl,1:+g,% Obj.HWND
		GuiControl,1:-Redraw,% Obj.HWND
	}DisableAll(Redraw:=1,Control:=""){
		for a,b in (Control?[this.All[Control]]:this.All){
			if(b.Label)
				GuiControl,% this.Win ":+g",% b.HWND
			if(Redraw)
				GuiControl,% this.Win ":-Redraw",% b.HWND
	}}DropFiles(Info*){
		this:=GUIClass.Table[A_Gui],Info.2:=this.GetName(Info.2),(Fun:=Func("DropFiles"))?Fun.Call(Info*)
	}EnableAll(Redraw:=1,Control:=""){
		for a,b in (Control?[this.All[Control]]:this.All){
			if(b.Label)
				GuiControl,% this.Win ":+g" b.Label,% b.HWND
			if(Redraw)
				GuiControl,% this.Win ":+Redraw",% b.HWND
	}}Escape(){
		KeyWait,Escape,U
		this:=GUIClass.Table[A_Gui],(Func:=Func("SavePos"))?Func.Call(this.Win,this.WinPos()):this.SavePos(),(Esc:=Func(A_Gui "Escape"))?Esc.Call()
		return 
	}Exit(){
		Exit:
		(Save:=Func("SavePos"))?Save.Call(this.Win,this.WinPos(this.HWND)):this.SavePos()
		ExitApp
		return
	}Focus(Control){
		this.Default(Control)
		ControlFocus,,% this.LookUp[Control].ID
	}Full(Control,Enable:=1){
		this.All[Control].Full:=Enable
	}Get(Control){
		return this.Add({Get:Control})
	}GetFocus(){
		ControlGetFocus,Focus,% this.ID
		ControlGet,HWND,HWND,,%Focus%,% this.ID
		return this.Con[HWND].Name
	}GetName(HWND){
		return this.Con[HWND].Name
	}GetPos(){
		Detect:=A_DetectHiddenWindows
		DetectHiddenWindows,On
		Gui,% this.Win ":Show",AutoSize Hide
		WinGet,CL,ControlListHWND,% this.ID
		Pos:=This.Winpos(),WW:=Pos.W,WH:=Pos.H,Flip:={X:"WW",Y:"WH"}
		for Index,HWND In StrSplit(CL,"`n"){
			Obj:=this.GUI[HWND]:=[]
			ControlGetPos,x,y,w,h,,ahk_id%hwnd%
			for c,d in StrSplit(this.Con[HWND].Pos)
				d~="w|h"?(obj[d]:=%d%-w%d%):d~="x|y"?(Obj[d]:=%d%-(d="y"?WH+this.Caption+this.Border:WW+this.Border))
		}DetectHiddenWindows,%Detect%
	}GetTV(Control){
		this.Default(Control)
		return TV_GetSelection()
	}Hotkeys(Keys){
		Hotkey,IfWinActive,% this.ID
		for a,b in Keys
			Hotkey,%a%,%b%,On
	}LoadPos(){
		IniRead,Pos,Settings.ini,% this.Win,Text,0
		IniRead,Max,Settings.ini,% this.Win,Max,0
		return {Pos:(Pos?Pos:""),Max:Max}
	}ResetHeaders(Info){
		/*
			m("Reset Headers",Info.Control)
		*/
		this.Headers[Info.Control]:=[]
		while(LV_GetCount("Columns"))
			LV_DeleteCol(1)
		for a,b in Info.Headers
			LV_InsertCol(a,"",b),this.Headers[Info.Control,b]:=1
	}SavePos(){
		Pos:=this.WinPos()
		if(Pos.Max=0){
			IniWrite,% Pos.Text,%A_ScriptDir%\Settings.ini,% this.Win,Text
			IniDelete,Settings.ini,% this.Win,Max
		}else if(Pos.Max=1)
			IniWrite,1,Settings.ini,% this.Win,Max
	}SetLV(Info){
		if(!Info.Control)
			return
		this.Default(Info.Control)
		if(Info.Headers){
			Info.Headers:=(IsObject(Info.Headers)?Info.Headers:StrSplit(Info.Headers,","))
			if(Info.Headers.Count()!=this.Headers[Info.Control].Count())
				this.ResetHeaders(Info)
			for a,b in Info.Headers{
				if(!this.Headers[Info.Control,b]){
					this.ResetHeaders(Info)
					Break
				}
			}
		}
		this.Default(Info.Control)
		if(!Info.Data.Count()){
			while(LV_GetCount("Columns"))
				LV_DeleteCol(1)
			return LV_Delete(),this.Headers[Info.Control]:=[]
		}if(Info.Clear)
			LV_Delete(),this.StoredLV[Info.Control]:=[]
		if(!this.StoredLV[Info.Control])
			this.StoredLV[Info.Control]:=[]
		if(Info.Data.1.HasKey(1)){
			for a,b in Info.Data
				LV_Add(Info.Options,b*),this.StoredLV[Info.Control].Push(b)
		}else{
			for a,b in Info.Data{
				Row:=[]
				for c,d in Info.Headers
					Row.Push(b[d])
				LV_Add(Info.Options,Row*)
		}}if(Info.AutoHDR){
			if(Info.AutoHDR=1)
				Loop,% LV_GetCount("Columns")
					LV_ModifyCol(A_Index,"AutoHDR")
			else
				for a,b in Info.AutoHDR
					LV_ModifyCol(b,"AutoHDR")
		}
	}SetText(Control,Text:=""){
		this.Default(Control)
		if((sc:=this.Var[Control].sc).sc){
			sc.2181(0,Text)
			/*
				Len:=VarSetCapacity(tt,StrPut(Text,"UTF-8")-1),StrPut(Text,&tt,Len,"UTF-8"),sc.2181(0,&tt)
			*/
		}else
			GuiControl,% this.Win ":",% this.Lookup[Control].HWND,%Text%
	}SetTV(Info){
		this.Default(Info.Control),(Info.Clear)?TV_Delete():"",(Info.Delete)?TV_Delete(Info.Delete):"",(Info.Text)?(TV:=TV_Add(Info.Text,(Info.Parent=1?TV_GetSelection():Info.Parent),Info.Options)):"",(Info.Text&&Info.Options&&Info.TV)?TV_Modify(Info.TV,Info.Options,Info.Text):""
		return TV
	}Show(name){
		this.GetPos(),Pos:=this.Resize=1?"":"AutoSize",this.name:=name
		if(this.Resize=1)
			Gui,% this.Win ":+Resize"
		GUIClass.ShowList.Push(this)
		this.ShowWindow()
	}ShowWindow(){
		while(this:=GUIClass.Showlist.Pop()){
			if(Show:=Func("Show"))
				Pos:=Show.Call(this.Win)
			else
				Pos:=this.LoadPos()
			Gui,% this.Win ":Show",Hide
			Pos1:=this.WinPos(),MinW:=Pos1.W,MinH:=Pos1.H
			Gui,% this.Win ":Show",% Pos.Pos,% this.Name
			if(this.Resize!=1)
				Gui,% this.Win ":Show",AutoSize
			if(Pos.Max)
				WinMaximize,% this.ID
			Gui,% this.Win ":+MinSize" MinW "x" MinH
			WinActivate,% this.id
		}
	}Size(){
		this:=IsObject(this)?this:GUIClass.Table[A_Gui],pos:=this.Winpos()
		for a,b in this.GUI
			for c,d in b
				GuiControl,% this.Win ":" (this.All[this.Con[a].Name].Type="ActiveX"?"Move":"MoveDraw"),%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}WinPos(HWND:=0){
		VarSetCapacity(Rect,16),DllCall("GetClientRect",Ptr,(HWND?HWND:this.HWND),Ptr,&Rect)
		WinGetPos,X,Y,,,% (HWND?"ahk_id" HWND:this.AhkID)
		W:=NumGet(Rect,8,Int),H:=NumGet(Rect,12,Int),Text:=(X!=""&&Y!=""&&W!=""&&H!="")?"X" X " Y" Y " W" W " H" H:""
		WinGet,Max,MinMax,% this.ID
		return {X:X,Y:Y,W:W,H:H,Text:Text,Max:Max}
	}
}
#SingleInstance,Force
if(){
	MsgBox,64,Nice,Nice,Nice
	ExitApp
}
/*
	Make it so that you bind the individual important things (Like S)
	to the Class not just have it do the overall bind so that you don't
	need to have version 11 of the Control
*/
MsgBox,% m("GO!","","Fight","","Win","btn:ync","ico:i","def:2")
ExitApp
ExitApp(){
	ExitApp
}
m(x*){
	static MsgBoxInstance,List:={OC:["OK","Cancel"],ARI:["Abort","Retry","Ignore"],YNC:["Yes","No","Cancel"],YN:["Yes","No"],RC:["Retry","Cancel"],CTC:["Cancel","Try Again","Continue"]},Ico:={"!":{Text:"&#x26A0;",Color:"Yellow"},X:{Text:"&#x2297;",Color:"Red"},"?":{Text:"&#x2753;",Color:"Blue"},I:{Text:"&#x24D8;",Color:"Blue"}}
	static m:=New MsgBoxClass()
	m:=New MsgBoxClass()
	for a,b in x{
		Obj:=StrSplit(b,":")
		if(Obj.1="Btn"&&Obj.2){
			Buttons:=1,(New:=(List[Obj.2].Clone())).Push("Clipboard"),m.AddButton(0,New*)
			Continue
		}
		else if(Obj.1="Ico"&&Obj.2)
			m.Img((Object:=Ico[Obj.2]).Text,,,,80),(OO:=m.Get("Icon")).Style.Overflow:="Hidden",OO.Style.Color:=Object.Color,Img:=1
		else if(Obj.1="Def"&&Obj.2)
			m.Default:=Obj.2
		else
			Msg.=(IsObject(b)?m.Obj2String(b):b) "`n"
	}m.Default:=m.Default?m.Default:1
	if(!Buttons)
		m.AddButton(0,"OK","Clipboard","Studio","ExitApp")
	for a,b in StrSplit(Trim(Msg,"`n"),"`n","`r`n"){
		if(b!="")
			New.="<p>" b "</p>"
		else
			New.="<hr/>"
	}
	Result:=m.Display(Trim(New,"`r`n"),0)
	if(Img)
		m.Img()
	return Result,m.Default:=1
}
Msg(x*){
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[]
	static Title
	list.title:="AHK Studio",list.def:=0,list.time:=0,value:=0,txt:=""
	WinGetTitle,Title,A
	for a,b in x
		Obj:=StrSplit(b,":"),(Obj.1="Bottom"?(Bottom:=1):""),(VV:=List[Obj.1,Obj.2])?(Value+=VV):(List[Obj.1]!="")?(List[Obj.1]:=Obj.2):TXT.=(b.XML?b.XML:IsObject(b)?Obj2String(b,,Bottom):b) "`n"
	;~ obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
			return b
	return
}
Class MsgBoxClass{
	Keep:=[]
	__New(Title:="",Owner:="",Win:="MsgBox"){
		local
		static
		Mode:=A_TitleMatchMode
		SetTitleMatchMode,3
		Win:=Win A_Now A_MSec
		this.File:=A_LineFile "\..\Settings.XML",this.XML:=ComObjCreate("MSXML2.DOMDocument"),this.XML.SetProperty("SelectionLanguage","XPath"),this.XML.Load(this.File)
		if(!this.XML.SelectSingleNode("//*"))
			this.XML.AppendChild(this.XML.CreateElement("Settings"))
		Gui,%Win%:Destroy
		Gui,%Win%:-Resize +HWNDMain -Caption +LabelMsgBoxClass.
		Gui,%Win%:Margin,0,0
		Ver:=this.FixIE(11),this.Action:=this.Action.Bind(this),this.SetHotkey(),this.Title:=Title?Title:A_ScriptName,this.MoveSize:=this.MoveSize.Bind(this),this.HWND:=Main
		Gui,%Win%:Add,ActiveX,w800 h400 vBrowser HWNDIE,mshtml
		Browser.Navigate("about:blank"),Browser.Silent:=1
		this.FixIE(Ver)
		while(Browser.ReadyState!=4)
			Sleep,10
		SysGet,Border,33
		SysGet,Caption,31
		SysGet,Edge,45
		RegRead,CheckReg,HKCU\SOFTWARE\Microsoft\Windows\DWM,ColorizationColor
		this.Doc:=Browser.Document
		this.Doc.Body.OuterHTML:="<Body><Div ID='WinForm' Style='Visibility:hidden'></Div><Div ID='OverAll'><Div ID='Header'><Div ID='Close' UnSelectable='on'>X</Div><Div ID='Save-Position' UnSelectable='on' Class='tooltip'>S<Span Class='ToolTipText' Style='Border:2px Solid Grey'>Save The MsgBox Position</Span></Div><Div ID='Title' UnSelectable='on'>" this.Title "</Div></Div><Div ID='ContentDiv'><Div><Img ID='Img' Style='Display:Flex;Width-0px;Flex-Direction:Column'/><p ID='Icon' Style='Float:Left;Color:Grey;Flex-Direction:Column;Text-Align:Center;Width:100%;Margin-Top:0px;OverFlow:Auto'/></Div><Div ID='Content'></Div></Div><Div ID='Buttons'></Div></Div><Styles ID='Styles'></Styles><Styles ID='Horizontal_Rule'>hr{display: block;height: 1px;border: 0;border-top: 1px solid #ccc;margin: 1em 0;padding: 0;}</Style><Style ID='P_Margin'>p{margin:0}</Style></Body>"
		this.Main:=Main
		MsgBoxClass.Keep[Main]:=this
		this.Buttons:=[]
		this.Dup:=[]
		this.Color:=(CC:=SubStr(Format("{:x}",CheckReg+0),-5))?CC:"AAAAAA"
		this.Border:=Border
		this.Caption:=Caption
		this.Edge:=Edge
		this.Body:=this.Doc.Body
		this.ID:="ahk_id" Main
		this.Win:=Win
		this.IE:=IE
		this.WB:=Browser
		this.Doc.ParentWindow.ahk_event:=this._Event.Bind(this)
		this.CreateElement("Script",,"onmousedown=function(event){ahk_event('MouseDown',event);" Chr(125) ";onclick=function(event){ahk_event('OnClick',event);" "}")
		this.Elements:={Buttons:{Position:"Absolute",Left:0,Right:0,Bottom:0,Height:"30px"},Header:{Position:"Absolute",Left:0,Right:0,Top:0},Content:{OverFlow:"Auto",Height:"100%",Color:"Pink",Width:"100%"},"Save-Position":{"Z-Index":2,Position:"Relative",Cursor:"Hand","Text-Align":"Center",Top:0,Color:"Black",Float:"Right",Width:"30px",Height:"20px","Line-Height":"20px",Background:this.Color},Close:{"Z-Index":4,Cursor:"Hand","Text-Align":"Center",Top:0,Color:"Black",Float:"Right",Right:0,Width:"30px",Height:"20px","Line-Height":"20px",Background:this.Color,Position:"Relative"},Title:{"Z-Index":1,"Line-Height":"20px","Height":"20px","White-Space":"NoWrap","OverFlow":"Hidden","Text-Overflow":"Ellipsis","Text-Align":"Center",Cursor:"Move",Background:this.Color},"Close:Hover":{Background:"Red","Border-Color":"Red"},"Close:Active":{Background:"Pink"},"Save-Position:Hover":{Background:"Blue"},Buttons:{Bottom:"0px",Left:"0px",Position:"Absolute",Display:"Flex",Height:"40px"},ContentDiv:{Position:"Absolute",Display:"Flex",Top:"20px",Bottom:"40px",Right:0,Left:0},Img:{Width:"0px"}}
		this.Arrows:=[]
		for a,b in this.Elements
			this.Update(a,b)
		for a,b in ["Up","Down","Left","Right"]
			this.Arrows.Push("*" b)
		this.Update(".tooltip",{Position:"Relative",Display:"Inline-Block"},1),this.Update(".tooltip .tooltiptext",{Width:"120px","Background-Color":"Black",Color:"#FFF","Text-Align":"Center","Border-Radius":"6px",Padding:"5px",Position:"Absolute","Z-Index":"8",Top:"10px",Right:"105%",Visibility:"Hidden"},1),this.Update(".tooltip:hover .tooltiptext",{Visibility:"Visible"},1),this.Update("HTML Body",{"Background":"Black"},1),this.Arrows.Push("Tab"),this.Arrows.Push("+Tab"),this.MainKeys:=this.MKeys.Bind(this),this.MainK:={Left:1,Right:1,Tab:1,"+Tab":1} ;,Enter:1}
		Hotkey,IfWinActive,% this.ID
		Hotkey,Enter,Select-Current-Element,On
		SetTitleMatchMode,%Mode%
		return this
		Select-Current-Element:
		for a,b in MsgBoxClass.Keep
			b.Doc.ActiveElement.Click()
		return
	}MKeys(Start:=0){
		if(!this.Doc.ActiveElement.ID)
			this.Buttons.1.Focus()
		for a,b in this.Buttons
			if(b.ID=this.Doc.ActiveElement.ID){
				Current:=a
				Break
			}
		Current:=Current?Current:this.Default,Current+=A_ThisHotkey~="\b(Tab|Right)\b"&&!InStr(A_ThisHotkey,"+")?1:-1,Current:=Current>this.Buttons.MaxIndex()?1:Current=0?this.Buttons.MaxIndex():Current,this.Buttons[this.Default&&Start?this.Default:Current].Focus()
	}_Event(Name,Event){
		local
		static
		Node:=Event.srcElement,CTRL:=this
		if((Node.NodeName="TD"||Node.ParentNode.NodeName="TD")&&Name="OnClick"){
			if(Node.GetElementsByTagName("Input").Item[0])
				ToolTip
			else{
				InputBox,NewInfo,Update Information,% "New Value For " Node.GetAttribute("Name"),,,,,,,,% Node.InnerText
				if(ErrorLevel)
					return
				this.XML.SelectSingleNode("//Window[" Node.ID "]").SetAttribute(Node.GetAttribute("Name"),NewInfo),Node.InnerText:=NewInfo,this.Save()
			}return
		}if(Name="MouseDown"){
			if(Node.ID="Title"){
				Mode:=A_CoordModeMouse
				CoordMode,Mouse,Screen
				MouseGetPos,x,y,Win
				WinGetPos,xx,yy,w,h,% this.ID
				Focus:=this.Document.ActiveElement,OffSetX:=xx-x,OffSetY:=yy-y,this.HWND:=Win,this.ID:="ahk_id" Win
				while(GetKeyState("LButton")){
					MouseGetPos,x,y
					WinMove,% this.ID,,% x+OffSetX,% y+OffSetY
					Sleep,10
				}SetTimer,MSGFocus,-10
				CoordMode,Mouse,%Mode%
				return
				MSGFocus:
				Focus.Focus()
				return
			}return
		}else if(Node.ID="Save-Position"){
			this.Get("OverAll").Style.Visibility:="Hidden",Form:=this.Get("WinForm"),this.Get("WinForm").Style.Visibility:="Visible",this.SetHotkey(0),EA:=this.EA(this.CurrentNode:=this.FindTitle(this.Window))
			if(!this.Get("Window-Title"))
				Form.AppendChild(New:=this.CreateElement("Div")),WW:="Type='Text' Style='Width:100%'",New.InnerHTML:="<Div>Window Title:</Div><Input ID='Window-Title' " WW "/><Div>Window Class:</Div><Input ID='Window-Class' " WW "/><Div>Window EXE:</Div><Input ID='Window-EXE' " WW "/><fieldset Style='Width:calc(100% - 35px)'><legend Style=''>Based On:</legend><Input Type='Checkbox' ID='Window-Height'/>Window Height<Div/><Button ID='Window-Pos' Name='Window'>Window Position</Button></fieldset></Div><Div></Div><Button ID='Window-Global' Name='Global' Style='Margin-Top:10px'>Global Position</Button><Style>Input:Focus{Background:Gold;outline:2px Solid Gold;" Chr(125) "</Style><Div ID='Table' Style='Padding-Top:10px'><table></table></Div><Style>table {Border-Collapse:Collapse;Border-Spacing:0;Width:100%;Border:2px Solid #ddd;" Chr(125) "td{Border:1px Solid #dddddd;Text-Align:Left;Padding:8px;" Chr(125) "td{Text-Align:Left;Padding:16px;Text-Align:Left;Cursor:Hand;" Chr(125) "th{Text-Align:Left;Padding:16px;Color:Red;" Chr(125) "</Style>"
			if(1){
				Table:=this.Doc.GetElementsByTagName("Table").Item[0],TP:=Table.ParentNode,Table.ParentNode.RemoveChild(Table),Table:=this.CreateElement("Table",,,TP)
				for a,b in {TR:(Headers:=["Title","Class","EXE"])}{
					Parent:=Table.AppendChild(this.CreateElement(a))
					for c,d in b
						Parent.AppendChild(this.CreateElement("TH",,d))
				}All:=this.XML.SelectNodes("//Window")
				while(aa:=All.Item[A_Index-1],ea1:=this.EA(aa)){
					Index:=A_Index,Parent:=Table.AppendChild(this.CreateElement("tr"))
					for a,b in Headers{
						Parent.AppendChild(TD:=this.CreateElement("td",,(b!="Height"?ea1[b]:""),,{ID:Index,Name:b}))
						if(b="Height"){
							TD.AppendChild(Check:=this.CreateElement("Input",,,,{Type:"Checkbox",ID:Index,Name:b}))
							if(ea1.Height)
								Check.SetAttribute("Checked","on")
			}}}}TP.Style.Width:="100%",(EA.Height)?this.Get("Window-Height").SetAttribute("Checked","On"):this.Get("Window-Height").RemoveAttribute("Checked"),MS:=this.MoveSize
			Hotkey,IfWinActive,% this.ID
			this.SetHotkey(0,this.MainKeys,this.MainK)
			for a,b in this.Arrows
				Hotkey,%b%,%MS%,On
			this.Update("HTML Body",{OverFlow:"Auto"},1)
			WinGetPos,x,y,w,h,% this.ID
			Gui,% this.Win ":+Resize"
			WinMove,% this.ID,,% x-(this.Border)+this.Edge,,% w+(this.Border*2)-(this.Edge*2),% h+(this.Border)-(this.Edge)+1
			for a,b in {Title:"Window-Title",Class:"Window-Class",EXE:"Window-EXE"}
				this.Get(b).Value:=this.CurrentNode?EA[a]:this.Window[a]
			this.BackgroundColor:=(OO:=this.Elements)["HTML Body","Background-Color"],this.Color:=OO["HTML Body"].Color,this.Update("HTML Body",{"Background-Color":"Black",Color:"Grey"},1),this.TabOrder:=[],this.OrderTab:=[]
			for a,b in ["Window-Title","Window-Class","Window-EXE","Window-Height","Window-Pos","Window-Global"]
				this.TabOrder.Push(b),this.OrderTab[b]:=A_Index
			return this.MoveSize(1)
		}if(Node.ID="Window-Pos"||Node.ID="Window-Global"){
			Win:=[],Win.Height:=this.Get("Window-Height").Checked?1:0,Win.Title:=this.Get("Window-Title").Value,Win.Class:=this.Get("Window-Class").Value,Win.EXE:=this.Get("Window-EXE").Value
			WinGetPos,x,y,w,h,% this.ID
			Gui,% this.Win ":-Resize"
			WinMove,A,,% (X:=x+this.Border-this.Edge),,% (W:=w-(this.Border*2)+(this.Edge*2)),% (H:=H-(this.Border-1))
			for a,b in this.Arrows
				Hotkey,%b%,Off
			WW:=this.WinPos(this.HWND),MW:=this.WinPos(this.Window.HWND),(Node.Name="Global")?(Win.Pos:="Global",Win.X:=WW.X,Win.Y:=WW.Y,Win.W:=WW.W,Win.H:=WW.H):(Win.Pos:="Window",Win.X:=WW.x-(MW.X+MW.W),Win.Y:=WW.Y-MW.Y,Win.W:=WW.W,Win.H:=(Win.Height?WW.H-MW.H:H))
			if(!IsObject(this.CurrentNode))
				this.CurrentNode:=this.AddNode("Window",Win)
			for a,b in Win
				this.CurrentNode.SetAttribute(a,b)
			if(Node.Name="Global"){
				for a,b in ["Height"]
					this.CurrentNode.RemoveAttribute(b)
				this.Get("Window-Height").RemoveAttribute("checked"),OO:=this.Get("Window-Height").Checked:=0
			}this.Save(),this.Set("OverAll",{Visibility:"Visible"}),this.Set("WinForm",{Visibility:"Hidden"}),this.Update("HTML Body",{"Background-Color":this.BackgroundColor,Color:this.Color},1),this.Update("HTML Body",{OverFlow:"Hidden"},1),this.Body.ScrollTop:="0px",this.Body.ScrollLeft:="0px",this.SetHotkey(1),this.SetHotkey(1,this.MainKeys,this.MainK)
			return
		}else if(IsFunc(Function:=Node.ID))
			%Function%(this)
		else if(Node.ID="Clipboard")
			Clipboard:=this.Response:=this.Text
		else if(Node.ID="Close"){
			this.Response:="CloseGUI"
			Gui,% this.Win ":Hide"
		}else if(Node.NodeName="Button")
			this.Response:=Node.Name?Node.Name:Node.ID
	}Action(){
		local
		Node:=this.Hotkeys[A_ThisHotkey]
		if(Node.ID="Studio"){
			DebugWindow((InStr(this.Text,"<p>")?Trim(RegExReplace(RegExReplace(RegExReplace(this.Text,"<p>","`n"),"</p>"),"<hr/>","`n------------------------------"),"`n"):this.Text))
			X:=Studio()
			v:=X.Get("v")
			v.Debug.2025(0)
			ExitApp
			X:=Studio()
			CEXML:=X.Get("CEXML")
			;here
			sc:=x.SC()
			All:=CEXML.SN("//*[@untitled]")
			while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
				if(InStr(ea.File,"Untitled1.ahk")&&aa.NodeName="File"){
					x.TV(ea.TV)
					while(sc.2357!=ea.SC){
						Sleep,10
					}
					X.SetText((InStr(this.Text,"<p>")?Trim(RegExReplace(RegExReplace(RegExReplace(this.Text,"<p>","`n"),"</p>"),"<hr/>","`n------------------------------"),"`n"):this.Text))
					ExitApp
				}
			}MsgBox,Open an Untitled
			ExitApp
		}
		if(Node.ID="Clipboard")
			return this.Response:="Clipboard",Clipboard:=(InStr(this.Text,"<p>")?Trim(RegExReplace(RegExReplace(RegExReplace(this.Text,"<p>","`n"),"</p>"),"<hr/>","`n------------------------------"),"`n"):this.Text)
		if(IsFunc(Function:=Node.ID))
			%Function%(this)
		else if(Node.NodeName="Button")
			this.Response:=Node.Name?Node.Name:Node.ID
	}AddButton(Buttons*){
		local
		for a,b in Buttons{
			b.Btn.InnerHTML:=b.Btn.Text?b.Btn.Text:(b.Btn.InnerHTML?b.Btn.InnerHTML:b.Btn.InnerText)
			if(!b){
				this.SetHotkey(0),this.Buttons:=[],this.Dup:=[],this.Hotkeys:=[]
				;here
				while(aa:=this.Doc.GetElementsByTagName("Button").Item[0])
					aa.ParentNode.RemoveChild(aa)
				Continue
			}if(this.Dup[(IsObject(b)?b.Btn.InnerHTML:b)]),this.Dup[(IsObject(b)?b.Btn.InnerHTML:b)]:=1
				Continue
			New:=this.CreateElement("Button",,,this.Doc.GetElementById("Buttons")),this.Buttons.Push(New)
			if(!IsObject(b)){
				New.InnerHTML:=b,New.ID:=RegExReplace(b,"\s","_")
				Continue
			}else{
				Btn:=b.Btn,Btn.InnerHTML:=Btn.InnerHTML,Btn.Delete("Text")
				if(!Btn.ID)
					Btn.ID:=RegExReplace(Btn.InnerHTML,"\s","_")
				for c,d in Btn
					New[c]:=d
				if(b.CSS)
					this.Update(Btn.ID,b.CSS)
		}}for a,b in this.Buttons{
			b.SetAttribute("Style","Z-Index:" A_Index ";Position:Relative;")
			for c,d in StrSplit(b.InnerHTML){
				if(!this.Hotkeys[d]&&d~="\w"&&!(b.InnerHtml="ExitApp"&&d="E")){
					this.Hotkeys[d]:=b,this.Hotkeys["!" d]:=b,b.InnerHTML:=(c>1?SubStr(b.InnerHTML,1,c-1):"") "<u>" SubStr(b.InnerHTML,c,1) "</u>" SubStr(b.InnerHTML,c+1)
					Break
		}}}this.SetHotkey(1)
	}AddNode(NodeName,Window){
		local
		if(!Node:=this.FindTitle(Window))
			Node:=this.XML.DocumentElement.AppendChild(this.XML.CreateElement(NodeName))
		for a,b in Window
			Node.SetAttribute(a,b)
		return Node
	}Close(){
		local
		Gui,% this.Win "Hide"
		this.Set("OverAll",{Visibility:"Visible"}),this.Set("WinForm",{Visibility:"Hidden"}),this.Update("HTML Body",{"Background-Color":this.BackgroundColor,Color:this.Color},1)
	}CompileTitle(ea){
		return ea.Title (ea.EXE?" ahk_exe " ea.EXE:"")(ea.Class?" ahk_class " ea.Class:"")
	}ConCat(Att,Text){
		local
		if(!Text)
			return "@" Att "='' or not(@" Att ")"
		Text:=(InStr(Text,"'"))?RegExReplace("concat('" RegExReplace(Text,"'","'," Chr(34) "'" Chr(34) ",'") "')","('',|,'')"):"'" Text "'",Text:="contains(" Text ",@" Att ") and @" Att "!='' or @" Att "=''"
		return Text
	}CreateElement(Type,ID:="",Text:="",Parent:="",Attributes:="",CSS:=""){
		local
		New:=this.Doc.CreateElement(Type),New.ID:=ID,New.InnerText:=Text,Parent?Parent.AppendChild(New):this.Body.AppendChild(New)
		for a,b in Attributes
			New.SetAttribute(a,b)
		if(CSS&&ID)
			this.Update(ID,CSS)
		return New
	}Display(Text,AsText:=1){
		local
		static Width,Height
		this.WinInfo:={Title:Title,Class:Class,EXE:Process}
		this.Get("Content")[(AsText?"InnerText":"InnerHTML")]:=(this.Text:=(IsObject(Text)?this.Obj2String(Text):Text))
		this.Window:=this.GetWindow()
		ea:=this.EA(this.FindTitle(this.Window))
		this.SetHotkey(1)
		Win:=this.WinPos(this.Window.HWND)
		(ea.Pos="Global")?(X:=ea.X,Y:=ea.Y,W:=ea.W,H:=ea.H):(ea.W)?(X:=Win.X+Win.W+ea.X,Y:=Win.Y+ea.Y,W:=ea.W,H:=((H:=(ea.Height?Win.H+ea.H:ea.H))>0?H:100)):""
		/*
			MsgBox,% "HERE!!!" (AsText?"InnerText":"InnerHTML") this.Get("Content").OuterHtml
			MsgBox,% AsText "`n`n",Text
		*/
		SysGet,MonitorCount,MonitorCount
		Gui,% this.Win ":Show",w%A_ScreenWidth% Hide
		this.Update("Content",{Width:"Auto"})
		Height:=this.Get("Content").ScrollHeight+this.Get("Buttons").ScrollHeight+this.Caption
		Width:=this.Get("Content").ScrollWidth+this.Border
		Sleep,10
		Buttons:=this.Get("Buttons").ScrollWidth
		this.Update("Content",{Width:"100%"})
		while(A_Index<=MonitorCount){
			SysGet,WA,MonitorWorkArea,%A_Index%
			if(X>=WALeft||Y>=WATop||X+W<=WARight||Y+H<=WABottom){
				Y:=Y>WATop&&Y<WABottom?Y:"Center",X:=X>WALeft&&X<WARight?X:"Center",W:=X+W<WARight&&W<=WARight-WALeft?W:WARight-X,H:=Y+H<WABottom&&H<=WABottom-WATop?(Height<100?100:H):WABottom-Y
				Break
		}}Pos:=(X!=""?"x" X:"")(Y!=""?" y" Y:"")(ea.W?" w" W:(Width<A_ScreenWidth&&Width>=Buttons?" w" Width:" w" Buttons))(H?" h" H:(Height<A_ScreenHeight?" h" Height:"")),this.SetHotkey(1,this.MainKeys,this.MainK),Owner:=this.Window.HWND
		if(Owner)
			Gui,% this.Win ":+Owner" Owner
		Gui,% this.Win ":Show",% (Pos?Pos:"xCenter yCenter w" (Width<A_ScreenWidth?Width:400) " h" (Height<A_ScreenHeight?Height:300)),% this.Title
		Pos:="",this.MKeys(1)
		while(!this.Response)
			Sleep,200
		Gui,% this.Win ":Hide"
		return this.Response,this.Response:=""
	}EA(Node){
		local
		EA:=[],All:=Node.SelectNodes("@*")
		while(aa:=All.Item[A_Index-1])
			EA[aa.NodeName]:=aa.Text
		return EA
	}Escape(){
		local
		KeyWait,Escape,U
		this:=MsgBoxClass.Keep[this],this.Body.ScrollTop:="0px",this.Body.ScrollLeft:="0px",this.Set("OverAll",{Visibility:"Visible"}),this.Set("WinForm",{Visibility:"Hidden"}),this.Update("HTML Body",{"Background-Color":this.BackgroundColor,Color:this.Color,OverFlow:"Hidden"},1),this.Response:="GuiEscape"
		Gui,% this.Win ":Default"
		Gui,-Resize
		Gui,Hide
		if(IsFunc(Escape:="Escape"))
			%Escape%()
	}FixIE(Version=0){ ;Thanks GeekDude
		local
		static Versions:={7:7000,8:8888,9:9999,10:10001,11:11001}
		Key:="Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
		Version:=Versions[Version]?Versions[Version]:Version
		if(A_IsCompiled)
			ExeName:=A_ScriptName
		else
			SplitPath,A_AhkPath,ExeName
		RegRead,PreviousValue,HKCU,%Key%,%ExeName%
		if(!Version)
			RegDelete,HKCU,%Key%,%ExeName%
		else{
			RegWrite,REG_DWORD,HKCU,%Key%,%ExeName%,%Version%
		}
		return PreviousValue
	}FindTitle(Info){
		local
		for a,b in {Title:Info.Title,Class:Info.Class,EXE:Info.EXE}
			Total.="(" this.ConCat(a,b) ") and "
		return this.XML.SelectSingleNode("//*[" Trim(Total," and ") "]")
	}Get(Control){
		return this.Doc.GetElementById(Control)
	}GetWindow(){
		local
		WinGetTitle,Title,A
		WinGetClass,Class,A
		WinGet,HWND,ID,A
		WinGet,Process,ProcessName,A
		WinGetPos,X,Y,W,H,A
		return {Title:Title,Class:Class,EXE:Process,X:X,Y:Y,W:W,H:H,HWND:HWND}
	}Img(Text:="",ImageLocation:="",Width:="",Height:="",FontSize:=""){
		local
		(Img:=this.Get("Img")).SRC:=ImageLocation,Img.Style.Width:=(Width?Width "px":Width),Img.Style.Height:=Height,(Icon:=this.Get("Icon")).InnerHTML:=Text
		if(FontSize)
			Icon.Style.FontSize:=FontSize "px"
		return {Img:Img,Icon:Icon}
	}MoveSize(Tab:=0){
		local
		Pos:=this.WinPos(),Keys:=[]
		for a,b in ["CTRL","ALT","Shift"]
			Keys[b]:=GetKeyState(b)
		if(!Keys.CTRL&&!Keys.ALT&&!Keys.Shift){
			Send,% "{" SubStr(A_ThisHotkey,2) "}"
			return
		}if(InStr(A_ThisHotkey,"Tab")||Tab)
			return Tab:=Round(this.OrderTab[this.Doc.ActiveElement.ID]),Tab+=InStr(A_ThisHotkey,"+")?-1:1,Tab:=Tab<1?this.TabOrder.MaxIndex():Tab>this.TabOrder.MaxIndex()?1:Tab,this.Get(this.TabOrder[Tab]).Focus()
		WinMove,% this.ID,,% (A_ThisHotkey~="\b(Left|Right)\b"&&!Keys.Alt?(Pos.X+(A_ThisHotkey="*Left"?(Keys.CTRL?-10:-1):(Keys.CTRL?10:1))):""),% (A_ThisHotkey~="\b(Up|Down)\b"&&!Keys.ALT?Pos.Y+(A_ThisHotkey="*Up"?(Keys.CTRL?-10:-1):(Keys.CTRL?10:1)):""),% (A_ThisHotkey~="\b(Left|Right)\b"&&Keys.ALT?(Pos.W+this.Border+(this.Edge*3)+(A_ThisHotkey="!Left"?(Keys.CTRL?-10:-1):(Keys.CTRL?10:1))):""),% (A_ThisHotkey~="\b(Up|Down)\b"&&Keys.Alt?Pos.H+this.Border+this.Border-(this.Edge)+(A_ThisHotkey="*Down"?(Keys.CTRL?10:1):(Keys.CTRL?-10:-1)):"")
	}Obj2String(Obj,FullPath:="Blank",BottomBlank:=0){
		local
		static String,Blank
		if(FullPath="Blank")
			FullPath:=String:=FullPath:=Blank:=""
		if(IsObject(Obj)){
			Try
				if(Obj.XML){
					if(Obj.XML.XML){
						Obj.Transform()
						return String.=FullPath "XML Object:`n" Obj[]
					}return String.=(FullPath?FullPath ".":"") Obj.XML "`n"
				}
			Try
				if(Obj.OuterHtml)
					return String.=FullPath "." Obj.OuterHtml "`n"
			Try
				for a,b in Obj{
					if(IsObject(b))
						this.Obj2String(b,FullPath "." a,BottomBlank)
					else{
						if(BottomBlank=0)
							String.=(FullPath?FullPath ".":"") a " = " b "`n"
						else if(b!="")
							String.=(FullPath?FullPath ".":"") "." a " = " b "`n"
						else
							Blank.=(FullPath?FullPath ".":"") "." a " =`n"
				}}
			Catch
				String.=FullPath ".Unknown Object Type`n"
		}return Trim(String Blank,"`n")
	}Save(){
		local
		if(!IsObject(XSL))
			XSL:=ComObjCreate("MSXML2.DOMDocument"),XSL.LoadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>"),Style:=null
		this.XML.TransformNodeToObject(XSL,this.XML),this.XML.Save(this.File)
	}Set(ID,Obj){
		local
		Style:=this.Get(ID).Style
		for a,b in Obj
			Style[a]:=b
	}SetHotkey(On:=0,Action:="",Keys:=""){
		local
		static Studio
		Keys:=Keys?Keys:this.Hotkeys
		if(!On){
			for a,b in Keys
				Try
					Hotkey,%a%,Off
			return
		}Action:=IsObject(Action)?Action:this.Action
		Hotkey,IfWinActive,% this.ID
		for a,b in Keys{
			Hotkey,%a%,%Action%,On
		}
	}Shadow(OffSetX:=4,OffSetY:=4,Color:="444",Controls:="All"){
		local
		for a,Control in (Controls="All"?["Header","Buttons","ContentDiv"]:[Controls]){
			this.Doc.GetElementById(Control)
			if(Control="Header")
				for a,b in [["Header",{"Margin-Bottom":OffSetY "px","Margin-Right":OffSetX "px"}],["Header > Div",{"Box-Shadow":OffSetX " " OffSetY "px " (SubStr(Color,1,1)="#"?"":"#") Color}],["ContentDiv",{Top:this.Doc.GetElementById(Control).OffSetHeight+OffSetY "px"}],["Save-Position:Active",{"Box-Shadow":"0 0 0",Transform:"TranslateX(" OffSetX "px)TranslateY(" OffSetY "px)"}],["Close:Active",{"Box-Shadow":"0 0 0",Transform:"TranslateX(" OffSetX "px)TranslateY(" OffSetY "px)"}]]
					this.Update(b*)
			if(Control="ContentDiv")
				this.Update(Control,{"Box-Shadow":OffSetX " " OffSetY "px " (SubStr(Color,1,1)="#"?"":"#") Color,"Margin-Right":OffSetX "px"})
			if(Control="Buttons")
				for a,b in [["ContentDiv",{Bottom:Round(this.Doc.GetElementById(Control).OffSetHeight+OffSetY) "px"}],["Buttons > Button",{"Box-Shadow":OffSetX " " OffSetY "px " (SubStr(Color,1,1)="#"?"":"#") Color}],["Buttons",{"Margin-Bottom":OffSetY "px","Margin-Right":OffSetX "px"}],["Buttons > Button:Active",{"Box-Shadow":"0 0 0",Transform:"TranslateX(" OffSetX "px)TranslateY(" OffSetY "px)"}]]
					this.Update(b*)
	}}Size(){
		local
		global MsgBoxClass
		Pos:=(this:=MsgBoxClass.Keep[this]).WinPos()
		ControlMove,,,,% Pos.W,% Pos.H,% "ahk_id" this.IE
	}Update(Control:="",Info:="",No#:="",Dot:=""){
		local
		if(!Control)
			return Elements
		if(!Obj:=this.Elements[Control])
			Obj:=this.Elements[Control]:=[]
		for a,b in Info
			Obj[a]:=b
		for a,b in Obj
			List.=a ":" b ";"
		if(!Update:=this.Doc.GetElementById(Control "Style"))
			Update:=this.Doc.CreateElement("Style"),Update.ID:=Control "Style",this.Doc.GetElementById("Styles").AppendChild(Update)
		Update.InnerText:=(No#?"":"#") Control "{" List "}"
	}WinPos(HWND:=""){
		local
		WinGetPos,X,Y,W,H,% "ahk_id" (HWND?HWND:this.Main)
		VarSetCapacity(Rect,16),DllCall("GetClientRect",Ptr,(HWND?HWND:this.Main),Ptr,&Rect)
		return {X:X,Y:Y,W:NumGet(Rect,8),H:NumGet(Rect,12)}
}}
/*
Obj2String(Obj,FullPath:="Blank",BottomBlank:=0){
	static String,Blank
	if(FullPath="Blank")
		FullPath:=String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		Try
			if(Obj.XML){
				if(Obj.XML.XML){
					Obj.Transform()
					return String.=FullPath "XML Object:`n" Obj[]
				}return String.=(FullPath?FullPath ".":"") Obj.XML "`n"
			}
		Try
			if(Obj.OuterHtml)
				return String.=FullPath "." Obj.OuterHtml "`n"
		Try
			for a,b in Obj{
				if(IsObject(b))
					Obj2String(b,FullPath "." a,BottomBlank)
				else{
					if(BottomBlank=0){
						String.=(FullPath?FullPath ".":"") a " = " b "`n"
					}else if(b!=""){
						String.=(FullPath?FullPath ".":"") "." a " = " b "`n"
					}else
						Blank.=(FullPath?FullPath ".":"") "." a " =`n"
				}
			}
		Catch
			String.=FullPath ".Unknown Object Type`n"
	}return Trim(String Blank,"`n")
}
*/
Obj2String(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
		String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		for a,b in Obj{
			if(IsObject(b)&&b.OuterHtml)
				String.=FullPath "." a " = " b.OuterHtml
			else if(IsObject(b)&&!b.XML)
				Obj2String(b,FullPath "." a,BottomBlank)
			else{
				if(BottomBlank=0)
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else if(b!="")
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
	}}
	return String Blank
}
DebugWindow(Text,Clear:=0,LineBreak:=0,Sleep:=0,AutoHide:=0,MsgBox:=0){
	x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}"),x.DebugWindow(Text,Clear,LineBreak,Sleep,AutoHide,MsgBox)
}
