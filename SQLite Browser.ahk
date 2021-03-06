#SingleInstance,Force
;menu SQLite Browser
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
	SmallWin.SetLV({Data:Files,Headers:"Files",Control:"File"})
	LV_Modify(1,"Select Vis Focus")
	SmallWin.Show("Choose File")
}else
	ShowBrowser(Files.1.1)
return
1Escape(){
	global
	MainWin.Exit()
}
2Escape(){
	ExitApp
}
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
		if((sc:=this.Var[Control].sc).sc)
			sc.2181(0,Text)
		else
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
Class MySQL{
	static Init:=0,Keep:=[]
	__New(){
		if(!MySQL.Init){
			SQLFile:=FileExist(FF:=A_ScriptDir "\SQLite3.dll")?FF:A_MyDocuments "\AutoHotkey\Lib\SQLite3.dll",this.Create:=[]
			if(!(DLL:=DllCall("LoadLibrary","Str",SQLFile,"UPtr"))){
				m("File: " SQLFile " does not exist. Exiting")
				ExitApp
			}this.DLL:=DLL,MySQL.Init:=1,MySQL.Keep[Object(this)]:=this
			return this
	}}Clean(Text,Special:=0){
		if(!Special)
			return RegExReplace(Text,"'","''")
		if(!InStr(Text,Chr(34))&&InStr(Text,"'"))
			return Chr(34) Text Chr(34)
		return "'" RegExReplace(Text,"'","''") "'"
	}Close(){
		DllCall("SQlite3.dll\sqlite3_close_v2",PTR,this.Handle)
	}CreatePWFile(File,Password){
		this.Open(":memory:"),this.Exec(Foo:="ATTACH DATABASE '" this.Clean(File) "' AS 'Foo' KEY '" this.Clean(Password) "'",A_ThisFunc "`n" A_LineNumber),this.Exec("DETACH DATABASE Foo",A_LineNumber),this.Close(),this.Open(File),this.Exec("PRAGMA KEY='" this.Clean(Password) "'",1)
	}Exec(SQL,Show*){
		for a,b in Show
			Debug.=b "`n"
		this.OO:=[],this.EA:=[],this.ErrorMsg:="",this.ErrorCode:=0,this.SQL:=SQL,this.Transaction:=&SQL
		if(!this.Handle){
			this.ErrorMsg:="Invalid dadabase handle!",(Debug)?m(this.ErrorMsg,SQL,Debug):""
			return 0
		}this.UTF8(SQL,UTF8),RC:=DllCall("SQlite3.dll\sqlite3_exec","Ptr",this.Handle,"Ptr",&UTF8,"Int",RegisterCallback("MySQL.ProcessQuery","FC",4),"Ptr",Object(this),"PtrP",Err,"CdeclInt"),CallError:=ErrorLevel
		if(CBPtr)
			DllCall("Kernel32.dll\GlobalFree","Ptr",CBPtr)
		if(CallError)
			return 0,this.ErrorMsg:="DLLCall sqlite3_exec failed!",this.ErrorCode:=CallError,(Debug)?m(this.ErrorMsg,this.ErrorCode,SQL,Debug):""
		if(RC)
			return 0,this.ErrorMsg:=StrGet(Err,"UTF-8"),this.ErrorCode:=RC,DllCall("SQLite3.dll\sqlite3_free","Ptr",Err),(Debug)?m("Error Message: " this.ErrorMsg,"Error Code: " this.ErrorCode,"SQL String: " SQL,Debug):""
		return this.EA
	}Exit(){
		Ret:=DllCall("FreeLibrary","UPtr",this.DLL)
		ExitApp
	}Insert(Table,Obj,Unique:="",NoQuote:=""){
		Columns:=[],NQ:=[]
		for a,b in StrSplit(NoQuote,",")
			NQ[b]:=1
		for a,b in Obj
			for c,d in b
				Columns[c]:=1
		for a,b in Obj{
			Col:=""
			for c,d in Columns{
				Val.=(NQ[c]?b[c]:this.ORNull(b[c])) ",",Col.=this.ORNull(c) ","
				if(!Init)
					Row.=this.ORNull(c) "=excluded." this.Clean(c) ","
			}Init:=1,TotalValues.="(" Trim(Val,",") "),",Val:=""
		}this.Exec(Foo:="INSERT INTO '" this.Clean(Table) "'(" Trim(Col,",") ") VALUES " Trim(TotalValues,",") (Unique?" ON CONFLICT([" this.Clean(Unique) "]) DO UPDATE SET " Trim(Row,","):""),A_LineNumber "`n" A_ThisFunc)
	}Open(File,Password:="",Debug:=1){
		if()
			m("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"","File: " File,"Password: " Password)
		if(Password&&!FileExist(File)){
			this.CreatePWFile(File,Password)
			return
		}
		DllCall("SQlite3.dll\sqlite3_enable_shared_cache",INT,1)
		this.UTF8(File,UTF8)
		RC:=DllCall("SQlite3.dll\sqlite3_open_v2","Ptr",&UTF8,"PtrP",HDB,"Int",6,"Ptr",0,"CdeclInt")
		if(ErrorLevel)
			return False,this._Path:="",this.ErrorMsg:="DLLCall sqlite3_open_v2 failed!",this.ErrorCode:=ErrorLevel,(Debug?m("Path: " this._Path,"Error Message: " this.ErrorMsg,"Error Code: " this.ErrorCode):"")
		if(RC)
			return False,this._Path:="",this.ErrorMsg:=this._ErrMsg(),this.ErrorCode:=RC,(Debug?m("Path: " this._Path,"Error Message: " this.ErrorMsg,"Error Code: " this.ErrorCode):"")
		this.Handle:=HDB
		if(Password){
			Enc:=this.Exec("PRAGMA encoding").1.Encoding
			/*
				m("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"",Enc)
			*/
			DBFile:=this.Exec("PRAGMA database_list").1.File
			this.Exec("PRAGMA KEY='" this.Clean(Password) "'")
			if(Enc=this.Exec("PRAGMA encoding").1.Encoding)
				return m("Database is not secure"),this.Close()
		}
		return 1
	}ORNull(Text){
		return Text!=""?Text+0?this.Clean(Text):Chr(34) RegExReplace(this.Clean(Text),"\x22",Chr(34) Chr(34)) Chr(34):"NULL"
	}ProcessQuery(Columns,ColumnText,ColumnNames){
		static Count:=0
		this:=MySQL.Keep[this],OO:=this.OO
		if(!OO.Columns){
			OO.Col:=[]
			Loop,%Columns%
				Col:=StrGet(NumGet(ColumnNames+((A_Index-1)*A_PtrSize)),"UTF-8"),Col:=Col="RowID"?"RowID":Col,OO.Columns.="|" Col,OO.Col.Push(Col)
			OO.Columns:=Trim(OO.Columns,"|")
		}
		if(!IsObject(OO.Values))
			OO.Values:=[],this.EA:=[]
		OO.Values.Push(Obj:=[]),this.EA.Push(EA:=[])
		for a,b in OO.Col{
			EA[b]:=StrGet(NumGet(ColumnText+((A_Index-1)*A_PtrSize)),"UTF-8")
			Obj.Push(Value:=StrGet(NumGet(ColumnText+((A_Index-1)*A_PtrSize)),"UTF-8")) ;,EA[b]:=Value
		}
	}Table(Table,SQL:="",Temporary:=0,Extra:=""){
		static Tables,Columns:=[]
		if(!IsObject(Tables)){
			Tables:=[]
			for a,b in this.Exec("SELECT name FROM sqlite_master WHERE type='table'",1)
				Tables[b.Name]:=1
		}if(SQL=0)
			return this.Exec("DROP TABLE '" this.Clean(Table) "'")
		else if(!SQL)
			return this.Create[Table]
		if(SQL=1)
			return Columns[Table]
		if(!Columns[Table])
			Columns[Table]:=RegExReplace(RegExReplace(RegExReplace(SQL,",UNIQUE\(.*")," PRIMARY KEY")," INTEGER")
		this.Create[Table]:=SQL
		if(!Tables[Table]){
			this.Exec("CREATE " (Temporary?"TEMPORARY":"") " TABLE IF NOT EXISTS '" this.Clean(Table) "'(" SQL ")" Extra,1)
			if(!Temporary)
				m("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"`n`n",this.SQL)
		}
	}UTF8(String,ByRef UTF8){
		VarSetCapacity(UTF8,StrPut(String,"UTF-8")),StrPut(String,&UTF8,"UTF-8")
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
Columns(a,b,c){
	if(b="C"||c="32"){
		ShowSQL()
	}
}
Delete(){
	for a,b in (Obj:=MainWin[]).Results{
		List.=b.1 ","
	}List:=Trim(List,","),Table:=Obj.Tables,Table:=Table[Table.MinIndex()].1
	if(List)
		MainWin.SetText("S","DELETE FROM '" DB.Clean(Table) "' WHERE OID IN (" List ")")
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
History_WindowEscape(){
	HistoryWin.Close()
}
History(){
	HistoryWin:=New GUIClass("History_Window",{Background:0,Color:"0xAAAAAA"})
	HistoryWin.Add("ListView,w500 h200 vHist,SQL Query,wh"
			    ,"Button,gPopulateHistory Default,Insert")
	HistoryWin.Show("History Window")
	HistoryWin.Default("Hist")
	HH:=[]
	for a,b in History
		HH.Push({History:a})
	HistoryWin.SetLV({Data:HH,Headers:"History",Control:"PopulateHistory"})
	return
	PopulateHistory:
	HH:=HistoryWin[].Hist
	MainWin.SetText("S",HH[HH.MinIndex()].1)
	return
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
LV_SubitemHitTest(HLV){ ;https://autohotkey.com/board/topic/80265-solved-which-column-is-clicked-in-listview/ Just Me
	VarSetCapacity(Point,8,0),DllCall("User32.dll\GetCursorPos",ptr,&Point),DllCall("User32.dll\ScreenToClient",ptr,HLV,ptr,&Point),VarSetCapacity(Info,24,0),NumPut(NumGet(Point,0,Int),Info,0,Int),NumPut(NumGet(Point,4,Int),Info,4,Int)
	SendMessage,0x1039,0,&Info,,ahk_id %HLV% ;LVM_SUBITEMHITTEST
	if(ErrorLevel=-1)
		return 0
	Subitem:=NumGet(Info,16,Int)+1
	return Subitem
}
m(x*){
	for a,b in x
		Msg.=(IsObject(b)?Obj2String(b):b) "`r`n"
	MsgBox,%Msg%
}
NoAction(){
	ShowSQL()
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
Open(){
	global
	File:=SmallWin[].File
	ShowBrowser(File[File.MinIndex()].1)
	SmallWin.SavePos(),SmallWin.Close()
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
Results(a,b,c){
	if(b="I"){
		if(MainWin[].Delete)
			Delete()
	}
}
SetWords(Extra:=""){
	Words:=OWords Extra
	Sort,Words,d`,
	Words:=StrSplit(Words,",")
}
ShowBrowser(File){
	global
	DB.Open(File)
	MainWin:=New GUIClass(1,{Background:0,Color:"0xAAAAAA"})
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
	MainWin.Show("SQLite Browser")
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
UpdateLimit(){
	Obj:=MainWin[]
	MainWin.SetText("S",RegExReplace(Obj.S,"i)Limit (\d+)?","Limit " Obj.Limit))
}
